// Prefix URLs with the current language code taken from the <html> tag.
const LANG_PREFIX = `/${document.documentElement.lang}`;

function onReady(fn) {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", fn);
  } else {
    fn();
  }
}

const popSound = new Audio('/static/audio/pop.wav');

// Load dynamic translations from the template if available
const JS_TRANSLATIONS = (() => {
  const el = document.getElementById('js-translations');
  if (!el) return {};
  try {
    return JSON.parse(el.textContent);
  } catch (e) {
    return {};
  }
})();

// Define CSRF helper locally in case layout.js hasn't been loaded
if (typeof getCSRFToken === "undefined") {
  function getCSRFToken() {
    const cookie = document.cookie
      .split("; ")
      .find((row) => row.startsWith("csrftoken="));
    return cookie ? cookie.split("=")[1] : "";
  }
}

onReady(() => {
  popSound.preload = "auto";
  const updateRelativeTimes = () => {
    document.querySelectorAll(".post-relative").forEach((el) => {
      const created = new Date(el.dataset.created);
      let minutes = Math.floor((Date.now() - created) / 60000);
      if (minutes < 1) minutes = 1;
      let text;
      if (minutes < 60) {
        text = minutes + "m";
      } else {
        let hours = Math.floor(minutes / 60);
        if (hours < 24) {
          text = hours + "h";
        } else {
          let days = Math.floor(hours / 24);
          if (days < 31) {
            text = days + "d";
          } else {
            let months = Math.floor(days / 30);
            if (months < 12) {
              text = months + "mo";
            } else {
              let years = Math.floor(months / 12);
              text = years + "y";
            }
          }
        }
      }
      el.textContent = text;
    });
  };
  updateRelativeTimes();
  setInterval(updateRelativeTimes, 60000);
  const storyInput = document.getElementById("id_media_file");
  if (storyInput) {
    storyInput.addEventListener("change", () => {
      document.getElementById("storyForm").submit();
    });
    const addBtn = document.querySelector(".story-add");
    if (addBtn && !addBtn.classList.contains("profile-story-add")) {
      addBtn.addEventListener("click", (e) => {
        e.stopPropagation();
        storyInput.click();
      });
    }
  }

  const storiesContainer = document.querySelector(".stories-container");
  const prevStories = document.querySelector(".stories-prev");
  const nextStories = document.querySelector(".stories-next");
  if (storiesContainer && (prevStories || nextStories)) {
    const itemWidth =
      storiesContainer.querySelector(".story-item")?.offsetWidth || 120;
    const gap = parseInt(getComputedStyle(storiesContainer).gap) || 0;
    const scrollAmount = itemWidth + gap;

    const updateStoryArrows = () => {
      const maxScroll =
        storiesContainer.scrollWidth - storiesContainer.clientWidth;
      const atStart = storiesContainer.scrollLeft <= 0;
      const atEnd = storiesContainer.scrollLeft >= maxScroll - 1;
      const noScroll = maxScroll <= 0;
      prevStories?.classList.toggle("d-none", atStart || noScroll);
      nextStories?.classList.toggle("d-none", atEnd || noScroll);
    };

    updateStoryArrows();
    storiesContainer.addEventListener("scroll", updateStoryArrows);
    window.addEventListener("resize", updateStoryArrows);

    prevStories?.addEventListener("click", () => {
      storiesContainer.scrollBy({ left: -scrollAmount, behavior: "smooth" });
    });
    nextStories?.addEventListener("click", () => {
      storiesContainer.scrollBy({ left: scrollAmount, behavior: "smooth" });
    });
  }

  document.querySelectorAll(".story-thumb").forEach((el) => {
    const color = el.dataset.bubbleColor;
    if (color) {
      el.style.setProperty("--story-color", color);
    }
  });

  let currentUrls = [];
  let currentTypes = [];
  let currentExpires = [];
  let currentIndex = 0;
  let prevIndex = 0;
  let progressTimeout;
  let countdownInterval;
  let storyStart = 0;
  let remainingTime = 5000;
  let progressPaused = false;

  const modal = document.getElementById("storyModal");
  const img = document.getElementById("storyImage");
  const video = document.getElementById("storyVideo");
  const progressBar = document.querySelector(".story-progress-bar");
  const modalContent = modal.querySelector(".story-modal");
  const storyOptions = document.querySelector(".story-options");
  const storyViews = document.querySelector(".story-views");
  const viewsModal = document.getElementById("storyViewsList");
  const viewsModalBody = viewsModal
    ? viewsModal.querySelector(".views-list-body")
    : null;
  const replyContainer = document.querySelector(".story-reply");
  const deleteBtn = document.querySelector(".btn-eliminar-historia");
  const replyInput = document.getElementById("storyReplyInput");
  const optionsBtn = document.querySelector(".story-options-btn");
  if (deleteBtn) deleteBtn.style.display = "none";
  let optionsOpen = false;
  const currentUsername = document.body.dataset.currentUser || "";

  const countdownEl = document.querySelector(".story-countdown");

  let currentStoryIds = [];
  let currentCreated = [];
  let currentIsOwn = false;
  let holdStart = 0;
  let skipNavClick = false;
  const HOLD_THRESHOLD = 200;
  let touchStartX = 0;

  function updateElapsed(createdIso) {
    if (!countdownEl) return;
    const created = new Date(createdIso).getTime();
    let diffMs = Date.now() - created;
    if (diffMs < 0) diffMs = 0;
    const totalSeconds = Math.floor(diffMs / 1000);
    if (totalSeconds < 60) {
      countdownEl.textContent = `${totalSeconds}s`;
    } else if (totalSeconds < 3600) {
      countdownEl.textContent = `${Math.floor(totalSeconds / 60)}m`;
    } else {
      countdownEl.textContent = `${Math.floor(totalSeconds / 3600)}h`;
    }
  }

  function pauseProgress() {
    if (progressPaused) return;
    progressPaused = true;
    clearTimeout(progressTimeout);
    const elapsed = Date.now() - storyStart;
    remainingTime = Math.max(0, 5000 - elapsed);
    if (progressBar) {
      const percent = Math.min(100, (elapsed / 5000) * 100);
      progressBar.style.transition = "none";
      progressBar.style.width = `${percent}%`;
    }
  }

  function resumeProgress() {
    if (!progressPaused) return;
    progressPaused = false;
    storyStart = Date.now();
    if (progressBar) {
      requestAnimationFrame(() => {
        progressBar.style.transition = `width ${remainingTime / 1000}s linear`;
        progressBar.style.width = "100%";
      });
    }
    clearTimeout(progressTimeout);
    progressTimeout = setTimeout(nextStory, remainingTime);
  }

  function showStory(idx) {
    if (viewsModal) viewsModal.classList.remove("show");
    const url = currentUrls[idx];
    const type = currentTypes[idx] || "";
    const direction = idx > prevIndex ? "left" : "right";
    prevIndex = idx;
    modal.style.setProperty("--bg-url", `url(${url})`);
    img.classList.remove("fade-in", "slide-left", "slide-right");
    video.classList.remove("fade-in", "slide-left", "slide-right");
    if (type.startsWith("video")) {
      video.src = url;
      video.classList.remove("d-none");
      img.classList.add("d-none");
      video.classList.add(direction === "left" ? "slide-left" : "slide-right", "fade-in");
    } else {
      img.src = url;
      img.classList.remove("d-none");
      video.classList.add("d-none");
      video.pause();
      img.classList.add(direction === "left" ? "slide-left" : "slide-right", "fade-in");
    }
    if (progressBar) {
      progressBar.style.transition = "none";
      progressBar.style.width = "0%";
      requestAnimationFrame(() => {
        progressBar.style.transition = "width 5s linear";
        progressBar.style.width = "100%";
      });
    }
    storyStart = Date.now();
    remainingTime = 5000;
    progressPaused = false;
    clearTimeout(progressTimeout);
    clearInterval(countdownInterval);
    updateElapsed(currentCreated[idx]);
    countdownInterval = setInterval(
      () => updateElapsed(currentCreated[idx]),
      1000
    );
    progressTimeout = setTimeout(nextStory, remainingTime);
    const replyBtn = document.getElementById("storyReplySend");
    if (replyBtn && currentStoryElIndex != null) {
      replyBtn.dataset.storyId = currentIsOwn ? "" : currentStoryIds[idx];
      replyBtn.disabled = currentIsOwn;
    }
    if (replyInput) {
      replyInput.disabled = currentIsOwn;
    }
    if (deleteBtn) deleteBtn.dataset.storyId = currentStoryIds[idx];
    fetch(`${LANG_PREFIX}/story/${currentStoryIds[idx]}/view/`, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((res) => res.json())
      .then((data) => {
        if (currentIsOwn && storyViews) {
          const countEl = storyViews.querySelector(".view-count");
          if (countEl) {
            const old = parseInt(countEl.textContent) || 0;
            countEl.textContent = data.views;
            if (data.views > old) {
              countEl.classList.add("animate-pop");
              setTimeout(() => countEl.classList.remove("animate-pop"), 300);
            }
          }
        }
      });
  }

  const storyEls = Array.from(document.querySelectorAll(".open-story"));
  let currentStoryElIndex = 0;

  function openStories(el, idx) {
    el.classList.add("viewed");
    popSound.currentTime = 0;
    popSound.play().catch(() => { });
    currentUrls = el.dataset.urls.split("|");
    currentTypes = el.dataset.types.split("|");
    currentExpires = el.dataset.expires.split("|");
    currentCreated = el.dataset.created.split("|");
    currentStoryIds = el.dataset.storyId.split("|");
    currentIndex = 0;
    prevIndex = 0;
    currentStoryElIndex = idx;
    currentIsOwn =
      el.dataset.own === "true" || el.dataset.user === currentUsername;
    const userContainer = document.querySelector(".story-modal-user");
    if (userContainer) {
      const profileUrl = el.dataset.profileUrl;
      const bubbleColor = el.dataset.bubbleColor || "#e0f5ff";
      userContainer.innerHTML = `<a href="${profileUrl}" class="post-user text-decoration-none" style="--bubble-color:${bubbleColor};">
            <img src="${el.dataset.avatarUrl}" class="post-avatar" width="40" height="40" alt="${el.dataset.user}">
            <strong>${el.dataset.user}</strong>
         </a>`;
    }
    const replyBtn = document.getElementById("storyReplySend");
    if (replyBtn) {
      replyBtn.dataset.storyId = currentIsOwn
        ? ""
        : currentStoryIds[currentIndex];
      replyBtn.disabled = currentIsOwn;
    }
    if (replyInput) replyInput.disabled = currentIsOwn;
    if (storyOptions)
      storyOptions.style.display = currentIsOwn ? "block" : "none";
    if (storyViews) {
      storyViews.style.display = currentIsOwn ? "flex" : "none";
      const countEl = storyViews.querySelector(".view-count");
      if (countEl) countEl.textContent = "";
      const eye = storyViews.querySelector("span:first-child");
      if (currentIsOwn && eye) {
        eye.style.animation = "none";
        void eye.offsetWidth;
        eye.style.animation = "";
      }
    }
    if (replyContainer) {
      if (currentIsOwn) {
        replyContainer.classList.add("d-none");
      } else {
        replyContainer.classList.remove("d-none");
      }
    }
    if (deleteBtn) {
      deleteBtn.dataset.storyId = currentStoryIds[currentIndex];
      deleteBtn.style.display = "none";
    }
    modal.style.display = "flex";
    modalContent.classList.add("open-anim");
    showStory(currentIndex);
  }

  function closeStories() {
    modal.style.display = "none";
    modalContent.classList.remove("open-anim");
    modal.style.removeProperty("--bg-url");
    clearTimeout(progressTimeout);
    clearInterval(countdownInterval);
    if (progressBar) progressBar.style.width = "0%";
    if (countdownEl) countdownEl.textContent = "";
    if (viewsModal) viewsModal.classList.remove("show");
    if (deleteBtn) deleteBtn.style.display = "none";
  }

  function nextStory() {
    if (currentIndex < currentUrls.length - 1) {
      currentIndex++;
      showStory(currentIndex);
    } else {
      const nextEl = storyEls[currentStoryElIndex + 1];
      if (nextEl) {
        openStories(nextEl, currentStoryElIndex + 1);
      } else {
        closeStories();
      }
    }
  }

  function prevStory() {
    if (currentIndex > 0) {
      currentIndex--;
      showStory(currentIndex);
    } else {
      const prevEl = storyEls[currentStoryElIndex - 1];
      if (prevEl) {
        openStories(prevEl, currentStoryElIndex - 1);
      } else {
        closeStories();
      }
    }
  }

  storyEls.forEach((el, idx) => {
    el.addEventListener("click", () => {
      openStories(el, idx);
    });
  });

  modalContent.addEventListener("mousedown", () => {
    holdStart = Date.now();
    pauseProgress();
  });

  modalContent.addEventListener("mouseup", () => {
    if (Date.now() - holdStart > HOLD_THRESHOLD) {
      skipNavClick = true;
    }
    if (
      (viewsModal && viewsModal.classList.contains("show")) ||
      optionsOpen ||
      (deleteConfirm && deleteConfirm.style.display === "flex")
    ) {
      return;
    }
    resumeProgress();
  });

  modalContent.addEventListener("touchstart", (e) => {
    holdStart = Date.now();
    pauseProgress();
    touchStartX = e.touches[0].clientX;
  });

  modalContent.addEventListener("touchend", (e) => {
    const diffX = e.changedTouches[0].clientX - touchStartX;
    if (Math.abs(diffX) > 50 && Date.now() - holdStart < HOLD_THRESHOLD) {
      if (diffX < 0) {
        nextStory();
      } else {
        prevStory();
      }
      resumeProgress();
      return;
    }
    if (Date.now() - holdStart > HOLD_THRESHOLD) {
      skipNavClick = true;
    }
    if (
      (viewsModal && viewsModal.classList.contains("show")) ||
      optionsOpen ||
      (deleteConfirm && deleteConfirm.style.display === "flex")
    ) {
      return;
    }
    resumeProgress();
  });

  // allow clicking on the content to navigate left/right
  modalContent.addEventListener("click", (e) => {
    if (skipNavClick) {
      skipNavClick = false;
      return;
    }
    if (e.target === modalContent || e.target === img || e.target === video) {
      const rect = modalContent.getBoundingClientRect();
      const clickX = e.clientX - rect.left;
      if (clickX > rect.width / 2) {
        nextStory();
      } else {
        prevStory();
      }
    }
  });

  // navigate using keyboard arrows
  document.addEventListener("keydown", (e) => {
    if (modal.style.display === "flex") {
      if (e.key === "ArrowRight") nextStory();
      if (e.key === "ArrowLeft") prevStory();
    }
  });

  document.querySelector(".story-next")?.addEventListener("click", nextStory);
  document.querySelector(".story-prev")?.addEventListener("click", prevStory);
  document
    .querySelector(".story-modal-close")
    ?.addEventListener("click", closeStories);

  const replyBtnEl = document.getElementById("storyReplySend");
  if (replyBtnEl) {
    replyBtnEl.addEventListener("click", () => {
      const storyId = replyBtnEl.dataset.storyId;
      const input = document.getElementById("storyReplyInput");
      const content = input ? input.value.trim() : "";
      if (!storyId || !content) return;
      const formData = new FormData();
      formData.append("content", content);
      fetch(`${LANG_PREFIX}/story/${storyId}/reply/`, {
        method: "POST",
        body: formData,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCSRFToken(),
        },
      })
        .then((res) => {
          if (!res.ok) return res.json().then((d) => Promise.reject(d));
          return res.json();
        })
        .then((data) => {
          if (input) input.value = "";
          if (data.chat_id) {
            window.location.href = `${LANG_PREFIX}/chat/${data.chat_id}/`;
          } else if (data.error) {
            alert(data.error);
          }
        })
        .catch(() => {
          alert("Error sending reply");
        });
    });

    if (replyInput) {
      replyInput.addEventListener("focus", pauseProgress);
      replyInput.addEventListener("input", pauseProgress);
      replyInput.addEventListener("blur", resumeProgress);
    }
  }

  const deleteConfirm = document.getElementById("deleteConfirm");
  const confirmDeleteBtn = document.getElementById("confirmDeleteStory");
  const cancelDeleteBtn = document.getElementById("cancelDeleteStory");
  let pendingDeleteId = null;

  if (deleteBtn && deleteConfirm && confirmDeleteBtn && cancelDeleteBtn) {
    deleteBtn.addEventListener("click", (e) => {
      e.preventDefault();
      pendingDeleteId = deleteBtn.dataset.storyId;
      if (!pendingDeleteId) {
        resumeProgress();
        return;
      }
      if (optionsOpen) optionsOpen = false;
      deleteBtn.style.display = "none";
      deleteConfirm.style.display = "flex";
      pauseProgress();
    });

    confirmDeleteBtn.addEventListener("click", () => {
      if (!pendingDeleteId) return;
      const deleteId = pendingDeleteId;
      fetch(`${LANG_PREFIX}/story/${deleteId}/delete/`, {
        method: "POST",
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCSRFToken(),
        },
        credentials: "same-origin",
      })
        .then((res) => (res.ok ? res.json() : Promise.reject()))
        .then((data) => {
          deleteConfirm.style.display = "none";
          const storyEl = storyEls[currentStoryElIndex];
          pendingDeleteId = null;
          resumeProgress();
          if (data.success && storyEl) {
            if (
              storyEl.classList.contains("user-story") ||
              storyEl.dataset.own === "true"
            ) {
              const clone = storyEl.cloneNode(true);
              clone.classList.remove("open-story");
              [
                "urls",
                "types",
                "expires",
                "created",
                "storyId",
                "own",
              ].forEach((attr) => clone.removeAttribute(`data-${attr}`));
              storyEl.parentNode.replaceChild(clone, storyEl);
              storyEls.splice(currentStoryElIndex, 1);
            } else {
              const item = storyEl.closest(".story-item");
              if (item) item.remove();
              storyEls.splice(currentStoryElIndex, 1);
            }
          }
          closeStories();
        })
        .catch(() => {
          deleteConfirm.style.display = "none";
          pendingDeleteId = null;
          resumeProgress();
        });
    });

    const hideDeleteModal = () => {
      deleteConfirm.style.display = "none";
      pendingDeleteId = null;
      resumeProgress();
    };

    cancelDeleteBtn.addEventListener("click", hideDeleteModal);
    deleteConfirm.addEventListener("click", (e) => {
      if (e.target === deleteConfirm) hideDeleteModal();
    });
  }

  if (storyViews && viewsModal && viewsModalBody) {
    storyViews.addEventListener("click", () => {
      const storyId = currentStoryIds[currentIndex];
      fetch(`${LANG_PREFIX}/story/${storyId}/viewers/`, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((res) => {
          if (!res.ok) throw new Error("HTTP " + res.status);
          return res.json();
        })
        .then((data) => {
          viewsModalBody.innerHTML = data.html;
          viewsModal.classList.add("show");
          pauseProgress();
        })
        .catch(() => {
          alert("Error loading viewers");
        });
    });

    viewsModal.addEventListener("click", (e) => {
      if (e.target === viewsModal) {
        viewsModal.classList.remove("show");
      }
    });
  }

  // Post deletion modal
  const postDeleteConfirm = document.getElementById("postDeleteConfirm");
  const confirmDeletePostBtn = document.getElementById("confirmDeletePost");
  const cancelDeletePostBtn = document.getElementById("cancelDeletePost");
  let pendingPostDeleteId = null;

  document.querySelectorAll(".delete-post-btn").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      pendingPostDeleteId = btn.dataset.postId;
      if (postDeleteConfirm) postDeleteConfirm.style.display = "flex";
    });
  });

  if (postDeleteConfirm && confirmDeletePostBtn && cancelDeletePostBtn) {
    confirmDeletePostBtn.addEventListener("click", () => {
      if (!pendingPostDeleteId) return;
      const deleteId = pendingPostDeleteId;
      fetch(`${LANG_PREFIX}/post/${deleteId}/delete/`, {
        method: "POST",
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCSRFToken(),
        },
      })
        .then((res) => res.json())
        .then((data) => {
          postDeleteConfirm.style.display = "none";
          const btn = document.querySelector(
            `.delete-post-btn[data-post-id='${deleteId}']`
          );
          const postEl = btn ? btn.closest(".post") : null;
          pendingPostDeleteId = null;
          if (data.success && postEl) {
            postEl.remove();
          }
        });
    });

    const hidePostDeleteModal = () => {
      postDeleteConfirm.style.display = "none";
      pendingPostDeleteId = null;
    };

    cancelDeletePostBtn.addEventListener("click", hidePostDeleteModal);
    postDeleteConfirm.addEventListener("click", (e) => {
      if (e.target === postDeleteConfirm) hidePostDeleteModal();
    });
  }

  // Comment deletion modal
  const commentDeleteConfirm = document.getElementById("commentDeleteConfirm");
  const confirmDeleteCommentBtn = document.getElementById(
    "confirmDeleteComment"
  );
  const cancelDeleteCommentBtn = document.getElementById("cancelDeleteComment");
  let pendingCommentDeleteId = null;

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".delete-comment-btn");
    if (btn) {
      e.preventDefault();
      pendingCommentDeleteId = btn.dataset.commentId;
      if (commentDeleteConfirm) commentDeleteConfirm.style.display = "flex";
    }
  });

  if (
    commentDeleteConfirm &&
    confirmDeleteCommentBtn &&
    cancelDeleteCommentBtn
  ) {
    confirmDeleteCommentBtn.addEventListener("click", () => {
      if (!pendingCommentDeleteId) return;
      const deleteId = pendingCommentDeleteId;
      fetch(`${LANG_PREFIX}/comment/${deleteId}/delete/`, {
        method: "POST",
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCSRFToken(),
        },
      })
        .then((res) => res.json())
        .then((data) => {
          commentDeleteConfirm.style.display = "none";
          const li = document.querySelector(
            `li[data-comment-id='${deleteId}']`
          );
          const list = li ? li.closest(".comment-list") : null;
          const postId = list ? list.dataset.postId : null;
          const repliesList = li ? li.closest(".respuestas") : null;
          const parentLi = repliesList
            ? repliesList.closest("li[data-comment-id]")
            : null;
          pendingCommentDeleteId = null;
          if (data.success && li) {
            li.remove();

            // If deleting a reply, hide the replies list and button when empty
            if (repliesList) {
              const remaining =
                repliesList.querySelectorAll(":scope > li").length;
              if (remaining === 0) {
                repliesList.classList.add("d-none");
                const hideBtn = parentLi
                  ? parentLi.querySelector(".hide-replies-btn")
                  : null;
                if (hideBtn) hideBtn.remove();
              }
            }

            if (postId) {
              const countSpan = document.querySelector(
                `.comment-count-wrapper[data-post-id='${postId}'] .comment-count`
              );
              if (countSpan)
                countSpan.textContent = Math.max(
                  0,
                  parseInt(countSpan.textContent) - 1
                );
              if (list && typeof data.remaining_top === "number") {
                const visible = list.querySelectorAll(":scope > li").length;
                if (data.remaining_top <= visible) {
                  const postEl = list.closest(".post");
                  if (postEl) {
                    const moreBtn = postEl.querySelector(".load-more-comments");
                    if (moreBtn) moreBtn.remove();
                    const showMoreBtn = postEl.querySelector(
                      ".show-more-comments"
                    );
                    if (showMoreBtn) showMoreBtn.remove();
                    if (data.remaining_top <= 3) {
                      const lessBtn = postEl.querySelector(
                        ".show-less-comments"
                      );
                      if (lessBtn) lessBtn.remove();
                    }
                  }
                }
              }
            }
          }
        });
    });

    const hideCommentDeleteModal = () => {
      commentDeleteConfirm.style.display = "none";
      pendingCommentDeleteId = null;
    };

    cancelDeleteCommentBtn.addEventListener("click", hideCommentDeleteModal);
    commentDeleteConfirm.addEventListener("click", (e) => {
      if (e.target === commentDeleteConfirm) hideCommentDeleteModal();
    });
  }

  if (optionsBtn) {
    const holdOptions = (e) => {
      e.stopPropagation();
      pauseProgress();
    };
    optionsBtn.addEventListener("mousedown", holdOptions);
    optionsBtn.addEventListener("touchstart", holdOptions);
    optionsBtn.addEventListener("mouseup", holdOptions);
    optionsBtn.addEventListener("touchend", holdOptions);
    optionsBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      optionsOpen = !optionsOpen;
      if (deleteBtn) deleteBtn.style.display = optionsOpen ? "block" : "none";
      if (optionsOpen) {
        pauseProgress();
      } else {
        resumeProgress();
      }
    });

    document.addEventListener("click", (e) => {
      if (optionsOpen && !storyOptions.contains(e.target)) {
        optionsOpen = false;
        if (deleteBtn) deleteBtn.style.display = "none";
        resumeProgress();
      }
    });
  }

  document.querySelectorAll(".like-post").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      fetch(btn.dataset.url, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((res) => res.json())
        .then((data) => {
          const span = btn.querySelector(".like-count");
          if (span) span.textContent = data.likes;
          btn.classList.add("animate-pop");
          setTimeout(() => btn.classList.remove("animate-pop"), 300);
        });
    });
  });

  function closeReply(container) {
    if (!container) return;
    container.classList.add("closing");
    container.classList.remove("show-form");
    setTimeout(() => container.classList.remove("closing"), 300);
  }

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".like-comment");
    if (btn) {
      e.preventDefault();
      fetch(btn.dataset.url, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((res) => res.json())
        .then((data) => {
          const span = btn.querySelector(".like-count");
          if (span) span.textContent = data.likes;
          btn.classList.add("animate-pop");
          setTimeout(() => btn.classList.remove("animate-pop"), 300);
        });
    }
  });

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".reply-btn");
    if (btn) {
      e.preventDefault();
      const container = btn.closest(".reply-inline-container");
      if (!container) return;
      container.classList.add("show-form");
      const input = container.querySelector(".reply-form .comment-input");
      if (input) input.focus();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      const form = e.target.closest(".reply-form");
      if (form) {
        const container = form.closest(".reply-inline-container");
        if (container) closeReply(container);
      }
    }
  });

  document.addEventListener(
    "blur",
    (e) => {
      const input = e.target.closest(".reply-form .comment-input");
      if (input) {
        const container = input.closest(".reply-inline-container");
        setTimeout(() => {
          if (
            !container.contains(document.activeElement) &&
            input.value.trim() === ""
          ) {
            closeReply(container);
          }
        }, 100);
      }
    },
    true
  );

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".load-more-comments");
    if (btn) {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById("comments-" + postId);
      const offset = list ? list.children.length : 0;
      fetch(`${LANG_PREFIX}/post/${postId}/comments/?offset=${offset}&limit=5`, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((res) => res.json())
        .then((data) => {
          if (list) {
            list.insertAdjacentHTML("beforeend", data.html);
          }
          let lessBtn = btn.parentElement
            ? btn.parentElement.querySelector(".show-less-comments")
            : null;
          if (!lessBtn) {
            lessBtn = document.createElement("button");
            lessBtn.className = "show-less-comments";
            lessBtn.dataset.postId = postId;
            lessBtn.textContent = JS_TRANSLATIONS.show_less || "Show less";
            btn.insertAdjacentElement("afterend", lessBtn);
          }
          if (!data.has_more) {
            btn.remove();
          }
          if (list) list.dataset.expanded = "true";
        });
    }
  });

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".show-less-comments");
    if (btn) {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById("comments-" + postId);
      if (list) {
        Array.from(list.children).forEach((li, idx) => {
          if (idx >= 3) li.style.display = "none";
        });
        list.dataset.expanded = "false";
      }
      const moreBtn = document.createElement("button");
      moreBtn.className = "show-more-comments";
      moreBtn.dataset.postId = postId;
      moreBtn.textContent = JS_TRANSLATIONS.show_more || "Show more";
      btn.replaceWith(moreBtn);
    }
  });

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".show-more-comments");
    if (btn) {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById("comments-" + postId);
      if (list) {
        Array.from(list.children).forEach((li) => {
          li.style.display = "";
        });
        list.dataset.expanded = "true";
      }
      const lessBtn = document.createElement("button");
      lessBtn.className = "show-less-comments";
      lessBtn.dataset.postId = postId;
      lessBtn.textContent = JS_TRANSLATIONS.show_less || "Show less";
      btn.replaceWith(lessBtn);
    }
  });

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".load-replies-btn");
    if (btn) {
      e.preventDefault();
      const commentId = btn.dataset.commentId;
      let list = document.getElementById("replies-" + commentId);
      const offset = list ? list.children.length : 0;
      fetch(`${LANG_PREFIX}/comment/${commentId}/replies/?offset=${offset}&limit=3`, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then((res) => res.json())
        .then((data) => {
          if (!list) {
            const li = document.querySelector(
              `li[data-comment-id='${commentId}']`
            );
            list = document.createElement("div");
            list.id = "replies-" + commentId;
            list.className = "respuestas list-group mt-1";
            if (li) li.appendChild(list);
          }
          list.classList.remove("d-none");
          list.insertAdjacentHTML("beforeend", data.html);
          let lessBtn = btn.parentElement
            ? btn.parentElement.querySelector(".hide-replies-btn")
            : null;
          if (!lessBtn) {
            lessBtn = document.createElement("button");
            lessBtn.className = "hide-replies-btn";
            lessBtn.dataset.commentId = commentId;
            lessBtn.textContent = JS_TRANSLATIONS.show_less || "Show less";
            btn.insertAdjacentElement("afterend", lessBtn);
          }
          if (!data.has_more) {
            btn.remove();
          }
        });
    }
  });

  document.addEventListener("click", (e) => {
    const btn = e.target.closest(".hide-replies-btn");
    if (btn) {
      e.preventDefault();
      const commentId = btn.dataset.commentId;
      const list = document.getElementById("replies-" + commentId);
      if (list) {
        list.innerHTML = "";
        list.classList.add("d-none");
      }
      const container = btn.parentElement;
      const existingMoreBtn = container
        ? container.querySelector(
          ".load-replies-btn[data-comment-id='" + commentId + "']"
        )
        : null;
      if (existingMoreBtn) {
        btn.remove();
      } else {
        const moreBtn = document.createElement("button");
        moreBtn.className = "load-replies-btn";
        moreBtn.dataset.commentId = commentId;
        moreBtn.textContent = JS_TRANSLATIONS.load_replies || "Load replies";
        btn.replaceWith(moreBtn);
      }
    }
  });

  // Submit new comments and replies via AJAX
  document.addEventListener("submit", (e) => {
    const commentForm = e.target.closest(".comment-form");
    const replyForm = e.target.closest(".reply-form");
    if (!commentForm && !replyForm) return;
    e.preventDefault();
    const form = commentForm || replyForm;
    const formData = new FormData(form);
    fetch(form.action, {
      method: "POST",
      body: formData,
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRFToken": getCSRFToken(),
      },
    })
      .then((res) => res.json())
      .then((data) => {
        if (!data.success) return;
        const countEl = document.querySelector(
          `.comment-count-wrapper[data-post-id='${data.post_id}'] .comment-count`
        );
        if (countEl) countEl.textContent = parseInt(countEl.textContent) + 1;
        if (commentForm) {
          let list = document.getElementById(`comments-${data.post_id}`);
          if (!list) {
            list = document.createElement("ul");
            list.id = `comments-${data.post_id}`;
            list.dataset.postId = data.post_id;
            list.dataset.expanded = "true";
            list.className = "list-group list-group-flush mt-2 comment-list";
            commentForm.insertAdjacentElement("afterend", list);
          }
          list.insertAdjacentHTML("beforeend", data.html);
          const input = commentForm.querySelector(".comment-input");
          if (input) input.value = "";

          const total = parseInt(
            countEl ? countEl.textContent : list.children.length
          );
          if (total > 3) {
            const postEl = commentForm.closest(".post");
            if (postEl) {
              const hasLess = postEl.querySelector(".show-less-comments");
              const hasMore = postEl.querySelector(
                ".load-more-comments, .show-more-comments"
              );
              if (!hasLess && !hasMore) {
                const lessBtn = document.createElement("button");
                lessBtn.className = "show-less-comments";
                lessBtn.dataset.postId = data.post_id;
                lessBtn.textContent = JS_TRANSLATIONS.show_less || "Show less";
                list.insertAdjacentElement("afterend", lessBtn);
              }
            }
          }
        } else if (replyForm) {
          const li = replyForm.closest("li[data-comment-id]");
          if (!li) return;
          let list = li.querySelector("div.respuestas");
          if (!list) {
            list = document.createElement("div");
            list.id = `replies-${li.dataset.commentId}`;
            list.className = "respuestas list-group mt-1";
            li.appendChild(list);
          }
          list.classList.remove("d-none");
          list.insertAdjacentHTML("beforeend", data.html);
          const input = replyForm.querySelector(".comment-input");
          if (input) input.value = "";
          const container = replyForm.closest(".reply-inline-container");
          if (container) {
            closeReply(container);
            const actions = container.parentElement;
            const loadBtn = actions
              ? actions.querySelector(".load-replies-btn")
              : null;
            const hideBtn = actions
              ? actions.querySelector(".hide-replies-btn")
              : null;
            if (!hideBtn && actions) {
              const newBtn = document.createElement("button");
              newBtn.className = "hide-replies-btn";
              newBtn.dataset.commentId = li.dataset.commentId;
              newBtn.textContent = JS_TRANSLATIONS.show_less || "Show less";
              if (loadBtn) loadBtn.replaceWith(newBtn);
              else actions.appendChild(newBtn);
            }
          }
        }
      });
  });

  window.addEventListener("scroll", () => {
    document.querySelectorAll(".comment-list").forEach((list) => {
      if (list.dataset.expanded !== "true") return;
      const post = list.closest(".post");
      if (!post) return;
      const rect = post.getBoundingClientRect();
      if (rect.bottom < 0 || rect.top > window.innerHeight) {
        Array.from(list.children).forEach((li, idx) => {
          if (idx >= 3) li.style.display = "none";
        });
        list.dataset.expanded = "false";
        const lessBtn = post.querySelector(".show-less-comments");
        if (lessBtn) {
          const moreBtn = document.createElement("button");
          moreBtn.className = "show-more-comments";
          moreBtn.dataset.postId = lessBtn.dataset.postId;
          moreBtn.textContent = JS_TRANSLATIONS.show_more || "Show more";
          lessBtn.replaceWith(moreBtn);
        }
      }
    });
  });
});
