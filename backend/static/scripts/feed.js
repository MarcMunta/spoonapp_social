document.addEventListener('DOMContentLoaded', () => {
  const updateRelativeTimes = () => {
    document.querySelectorAll('.post-relative').forEach(el => {
      const created = new Date(el.dataset.created);
      let minutes = Math.floor((Date.now() - created) / 60000);
      if (minutes < 1) minutes = 1;
      let text;
      if (minutes < 60) {
        text = minutes + 'm';
      } else {
        let hours = Math.floor(minutes / 60);
        if (hours < 24) {
          text = hours + 'h';
        } else {
          let days = Math.floor(hours / 24);
          if (days < 31) {
            text = days + 'd';
          } else {
            let months = Math.floor(days / 30);
            if (months < 12) {
              text = months + 'mo';
            } else {
              let years = Math.floor(months / 12);
              text = years + 'y';
            }
          }
        }
      }
      el.textContent = text;
    });
  };
  updateRelativeTimes();
  setInterval(updateRelativeTimes, 60000);
  const storyInput = document.getElementById('id_media_file');
  if (storyInput) {
    storyInput.addEventListener('change', () => {
      document.getElementById('storyForm').submit();
    });
    const addBtn = document.querySelector('.story-add');
    if (addBtn) {
      addBtn.addEventListener('click', e => {
        e.stopPropagation();
        storyInput.click();
      });
    }
  }

  const storiesContainer = document.querySelector('.stories-container');
  const prevStories = document.querySelector('.stories-prev');
  const nextStories = document.querySelector('.stories-next');
  if (storiesContainer && (prevStories || nextStories)) {
    const itemWidth = storiesContainer.querySelector('.story-item')?.offsetWidth || 120;
    const gap = parseInt(getComputedStyle(storiesContainer).gap) || 0;
    const scrollAmount = itemWidth + gap;

    const updateStoryArrows = () => {
      const maxScroll = storiesContainer.scrollWidth - storiesContainer.clientWidth;
      const atStart = storiesContainer.scrollLeft <= 0;
      const atEnd = storiesContainer.scrollLeft >= maxScroll - 1;
      const noScroll = maxScroll <= 0;
      prevStories?.classList.toggle('d-none', atStart || noScroll);
      nextStories?.classList.toggle('d-none', atEnd || noScroll);
    };

    updateStoryArrows();
    storiesContainer.addEventListener('scroll', updateStoryArrows);
    window.addEventListener('resize', updateStoryArrows);

    prevStories?.addEventListener('click', () => {
      storiesContainer.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
    });
    nextStories?.addEventListener('click', () => {
      storiesContainer.scrollBy({ left: scrollAmount, behavior: 'smooth' });
    });
  }

  let currentUrls = [];
  let currentExpires = [];
  let currentTypes = [];
  let currentIndex = 0;
  let progressTimeout;
  let countdownInterval;
  let storyStart = 0;
  let remainingTime = 5000;
  let progressPaused = false;

  const modal = document.getElementById('storyModal');
  const img = document.getElementById('storyImage');
  const video = document.getElementById('storyVideo');
  const progressBar = document.querySelector('.story-progress-bar');
  const modalContent = modal.querySelector('.story-modal-content');
  const storyOptions = document.querySelector('.story-options');
  const storyViews = document.querySelector('.story-views');
  const replyContainer = document.querySelector('.story-reply');
  const deleteBtn = document.querySelector('.story-delete');
  const replyInput = document.getElementById('storyReplyInput');
  const optionsBtn = document.querySelector('.story-options-btn');
  const optionsMenu = storyOptions ? storyOptions.querySelector('.dropdown-menu') : null;
  const currentUsername = document.body.dataset.currentUser || '';

  const countdownEl = document.querySelector('.story-countdown');

  let currentStoryIds = [];
  let currentIsOwn = false;

  function updateCountdown(expireIso) {
    if (!countdownEl) return;
    const created = new Date(new Date(expireIso).getTime() - 24 * 60 * 60 * 1000);
    const diff = Date.now() - created.getTime();
    if (diff <= 0) {
      countdownEl.textContent = '0m';
      return;
    }
    const minutes = Math.floor(diff / 60000);
    if (minutes < 60) {
      countdownEl.textContent = `${minutes}m`;
    } else {
      const hours = Math.floor(minutes / 60);
      countdownEl.textContent = `${hours}h`;
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
      progressBar.style.transition = 'none';
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
        progressBar.style.width = '100%';
      });
    }
    clearTimeout(progressTimeout);
    progressTimeout = setTimeout(nextStory, remainingTime);
  }

  function showStory(idx) {
    const url = currentUrls[idx];
    const type = currentTypes[idx] || '';
    if (type.startsWith('video')) {
      video.src = url;
      video.classList.remove('d-none');
      img.classList.add('d-none');
    } else {
      img.src = url;
      img.classList.remove('d-none');
      video.classList.add('d-none');
      video.pause();
    }
    if (progressBar) {
      progressBar.style.transition = 'none';
      progressBar.style.width = '0%';
      requestAnimationFrame(() => {
        progressBar.style.transition = 'width 5s linear';
        progressBar.style.width = '100%';
      });
    }
    storyStart = Date.now();
    remainingTime = 5000;
    progressPaused = false;
    clearTimeout(progressTimeout);
    clearInterval(countdownInterval);
    updateCountdown(currentExpires[idx]);
    countdownInterval = setInterval(() => updateCountdown(currentExpires[idx]), 1000);
    progressTimeout = setTimeout(nextStory, remainingTime);
    const replyBtn = document.getElementById('storyReplySend');
    if (replyBtn && currentStoryElIndex != null) {
      replyBtn.dataset.storyId = currentIsOwn ? '' : currentStoryIds[idx];
      replyBtn.disabled = currentIsOwn;
    }
    if (replyInput) {
      replyInput.disabled = currentIsOwn;
    }
    if (deleteBtn) deleteBtn.dataset.storyId = currentStoryIds[idx];
    fetch(`/story/${currentStoryIds[idx]}/view/`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
      .then(res => res.json())
      .then(data => {
        if (currentIsOwn && storyViews) {
          storyViews.textContent = `${data.views} views`;
        }
      });
  }

  const storyEls = Array.from(document.querySelectorAll('.open-story'));
  let currentStoryElIndex = 0;

  function openStories(el, idx) {
    currentUrls = el.dataset.urls.split('|');
    currentTypes = el.dataset.types.split('|');
    currentExpires = el.dataset.expires.split('|');
    currentStoryIds = el.dataset.storyId.split('|');
    currentIndex = 0;
    currentStoryElIndex = idx;
    currentIsOwn = el.dataset.own === 'true' || el.dataset.user === currentUsername;
    const userContainer = document.querySelector('.story-modal-user');
    if (userContainer) {
      const profileUrl = el.dataset.profileUrl;
      const avatarHtml =
        `<a href="${profileUrl}"><img src="${el.dataset.avatarUrl}" class="story-modal-avatar me-2" width="40" height="40" alt="${el.dataset.user}"></a>`;
      const nameHtml =
        `<a href="${profileUrl}" class="story-modal-name text-white fs-5">${el.dataset.user}</a>`;
      userContainer.innerHTML = avatarHtml + nameHtml;
    }
    const replyBtn = document.getElementById('storyReplySend');
    if (replyBtn) {
      replyBtn.dataset.storyId = currentIsOwn ? '' : currentStoryIds[currentIndex];
      replyBtn.disabled = currentIsOwn;
    }
    if (replyInput) replyInput.disabled = currentIsOwn;
    if (storyOptions) storyOptions.style.display = currentIsOwn ? 'block' : 'none';
    if (storyViews) storyViews.style.display = currentIsOwn ? 'block' : 'none';
    if (replyContainer) {
      if (currentIsOwn) {
        replyContainer.classList.add('d-none');
      } else {
        replyContainer.classList.remove('d-none');
      }
    }
    if (deleteBtn) deleteBtn.dataset.storyId = currentStoryIds[currentIndex];
    modal.style.display = 'flex';
    modalContent.classList.add('open-anim');
    showStory(currentIndex);
  }

  function closeStories() {
    modal.style.display = 'none';
    modalContent.classList.remove('open-anim');
    clearTimeout(progressTimeout);
    clearInterval(countdownInterval);
    if (progressBar) progressBar.style.width = '0%';
    if (countdownEl) countdownEl.textContent = '';
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
    el.addEventListener('click', () => {
      openStories(el, idx);
    });
  });

  // allow clicking on the content to navigate left/right
  modalContent.addEventListener('click', e => {
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
  document.addEventListener('keydown', e => {
    if (modal.style.display === 'flex') {
      if (e.key === 'ArrowRight') nextStory();
      if (e.key === 'ArrowLeft') prevStory();
    }
  });

  document.querySelector('.story-next')?.addEventListener('click', nextStory);
  document.querySelector('.story-prev')?.addEventListener('click', prevStory);
  document.querySelector('.story-modal-close')?.addEventListener('click', closeStories);

  const replyBtnEl = document.getElementById('storyReplySend');
  if (replyBtnEl) {
    replyBtnEl.addEventListener('click', () => {
      const storyId = replyBtnEl.dataset.storyId;
      const input = document.getElementById('storyReplyInput');
      const content = input ? input.value.trim() : '';
      if (!storyId) return;
      const formData = new FormData();
      formData.append('content', content);
      fetch(`/story/${storyId}/reply/`, {
        method: 'POST',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRFToken': getCSRFToken()
        }
      })
        .then(res => res.json())
        .then(data => {
          if (input) input.value = '';
          if (data.chat_id) {
            window.location.href = `/chat/${data.chat_id}/`;
          }
        });
    });

    if (replyInput) {
      replyInput.addEventListener('focus', pauseProgress);
      replyInput.addEventListener('input', pauseProgress);
      replyInput.addEventListener('blur', resumeProgress);
    }
  }

  const deleteConfirm = document.getElementById('deleteConfirm');
  const confirmDeleteBtn = document.getElementById('confirmDeleteStory');
  const cancelDeleteBtn = document.getElementById('cancelDeleteStory');
  let pendingDeleteId = null;

  if (deleteBtn && deleteConfirm && confirmDeleteBtn && cancelDeleteBtn) {
    deleteBtn.addEventListener('click', e => {
      e.preventDefault();
      pendingDeleteId = deleteBtn.dataset.storyId;
      if (!pendingDeleteId) {
        resumeProgress();
        return;
      }
      deleteConfirm.style.display = 'flex';
      pauseProgress();
    });

    confirmDeleteBtn.addEventListener('click', () => {
      if (!pendingDeleteId) return;
      const deleteId = pendingDeleteId;
      fetch(`/story/${deleteId}/delete/`, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'X-CSRFToken': getCSRFToken() }
      }).then(res => res.json()).then(data => {
        deleteConfirm.style.display = 'none';
        const storyEl = storyEls[currentStoryElIndex];
        pendingDeleteId = null;
        resumeProgress();
        if (data.success && storyEl) {
          const item = storyEl.closest('.story-item');
          if (item) item.remove();
          storyEls.splice(currentStoryElIndex, 1);
        }
        closeStories();
      });
    });

    const hideDeleteModal = () => {
      deleteConfirm.style.display = 'none';
      pendingDeleteId = null;
      resumeProgress();
    };

    cancelDeleteBtn.addEventListener('click', hideDeleteModal);
    deleteConfirm.addEventListener('click', e => {
      if (e.target === deleteConfirm) hideDeleteModal();
    });
  }

  // Post deletion modal
  const postDeleteConfirm = document.getElementById('postDeleteConfirm');
  const confirmDeletePostBtn = document.getElementById('confirmDeletePost');
  const cancelDeletePostBtn = document.getElementById('cancelDeletePost');
  let pendingPostDeleteId = null;

  document.querySelectorAll('.delete-post-btn').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      pendingPostDeleteId = btn.dataset.postId;
      if (postDeleteConfirm) postDeleteConfirm.style.display = 'flex';
    });
  });

  if (postDeleteConfirm && confirmDeletePostBtn && cancelDeletePostBtn) {
    confirmDeletePostBtn.addEventListener('click', () => {
      if (!pendingPostDeleteId) return;
      const deleteId = pendingPostDeleteId;
      fetch(`/post/${deleteId}/delete/`, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'X-CSRFToken': getCSRFToken() }
      }).then(res => res.json()).then(data => {
        postDeleteConfirm.style.display = 'none';
        const btn = document.querySelector(`.delete-post-btn[data-post-id='${deleteId}']`);
        const postEl = btn ? btn.closest('.post') : null;
        pendingPostDeleteId = null;
        if (data.success && postEl) {
          postEl.remove();
        }
      });
    });

    const hidePostDeleteModal = () => {
      postDeleteConfirm.style.display = 'none';
      pendingPostDeleteId = null;
    };

    cancelDeletePostBtn.addEventListener('click', hidePostDeleteModal);
    postDeleteConfirm.addEventListener('click', e => {
      if (e.target === postDeleteConfirm) hidePostDeleteModal();
    });
  }

  // Comment deletion modal
  const commentDeleteConfirm = document.getElementById('commentDeleteConfirm');
  const confirmDeleteCommentBtn = document.getElementById('confirmDeleteComment');
  const cancelDeleteCommentBtn = document.getElementById('cancelDeleteComment');
  let pendingCommentDeleteId = null;

  document.addEventListener('click', e => {
    const btn = e.target.closest('.delete-comment-btn');
    if (btn) {
      e.preventDefault();
      pendingCommentDeleteId = btn.dataset.commentId;
      if (commentDeleteConfirm) commentDeleteConfirm.style.display = 'flex';
    }
  });

  if (commentDeleteConfirm && confirmDeleteCommentBtn && cancelDeleteCommentBtn) {
    confirmDeleteCommentBtn.addEventListener('click', () => {
      if (!pendingCommentDeleteId) return;
      const deleteId = pendingCommentDeleteId;
      fetch(`/comment/${deleteId}/delete/`, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'X-CSRFToken': getCSRFToken() }
      }).then(res => res.json()).then(data => {
        commentDeleteConfirm.style.display = 'none';
        const li = document.querySelector(`li[data-comment-id='${deleteId}']`);
        const list = li ? li.closest('.comment-list') : null;
        const postId = list ? list.dataset.postId : null;
        const repliesList = li ? li.closest('.replies-list') : null;
        const parentLi = repliesList ? repliesList.closest('li[data-comment-id]') : null;
        pendingCommentDeleteId = null;
        if (data.success && li) {
          li.remove();

          // If deleting a reply, hide the replies list and button when empty
          if (repliesList) {
            const remaining = repliesList.querySelectorAll(':scope > li').length;
            if (remaining === 0) {
              repliesList.classList.add('d-none');
              const hideBtn = parentLi ? parentLi.querySelector('.hide-replies-btn') : null;
              if (hideBtn) hideBtn.remove();
            }
          }

          if (postId) {
            const countSpan = document.querySelector(`.comment-count-wrapper[data-post-id='${postId}'] .comment-count`);
            if (countSpan) countSpan.textContent = Math.max(0, parseInt(countSpan.textContent) - 1);
            if (list && typeof data.remaining_top === 'number') {
              const visible = list.querySelectorAll(':scope > li').length;
              if (data.remaining_top <= visible) {
                const postEl = list.closest('.post');
                if (postEl) {
                  const moreBtn = postEl.querySelector('.load-more-comments');
                  if (moreBtn) moreBtn.remove();
                  const showMoreBtn = postEl.querySelector('.show-more-comments');
                  if (showMoreBtn) showMoreBtn.remove();
                  if (data.remaining_top <= 5) {
                    const lessBtn = postEl.querySelector('.show-less-comments');
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
      commentDeleteConfirm.style.display = 'none';
      pendingCommentDeleteId = null;
    };

    cancelDeleteCommentBtn.addEventListener('click', hideCommentDeleteModal);
    commentDeleteConfirm.addEventListener('click', e => {
      if (e.target === commentDeleteConfirm) hideCommentDeleteModal();
    });
  }

  if (optionsBtn && optionsMenu) {
    optionsBtn.addEventListener('click', e => {
      e.stopPropagation();
      const open = optionsMenu.classList.contains('show');
      if (open) {
        optionsMenu.classList.remove('show');
        resumeProgress();
      } else {
        optionsMenu.classList.add('show');
        pauseProgress();
      }
    });

    document.addEventListener('click', e => {
      if (!storyOptions.contains(e.target) && optionsMenu.classList.contains('show')) {
        optionsMenu.classList.remove('show');
        resumeProgress();
      }
    });
  }

  document.querySelectorAll('.like-post').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      fetch(btn.dataset.url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
          const span = btn.querySelector('.like-count');
          if (span) span.textContent = data.likes;
          btn.classList.add('animate-pop');
          setTimeout(() => btn.classList.remove('animate-pop'), 300);
        });
    });
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.like-comment');
    if (btn) {
      e.preventDefault();
      fetch(btn.dataset.url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
          const span = btn.querySelector('.like-count');
          if (span) span.textContent = data.likes;
          btn.classList.add('animate-pop');
          setTimeout(() => btn.classList.remove('animate-pop'), 300);
        });
    }
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.reply-btn');
    if (btn) {
      e.preventDefault();
      const container = btn.parentElement;
      const form = container ? container.nextElementSibling : null;
      if (form) {
        form.classList.toggle('d-none');
        const input = form.querySelector('.comment-input');
        if (input && !form.classList.contains('d-none')) {
          input.focus();
        }
      }
    }
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.load-more-comments');
    if (btn) {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById('comments-' + postId);
      const offset = list ? list.children.length : 0;
      fetch(`/post/${postId}/comments/?offset=${offset}&limit=10`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
          if (list) {
            list.insertAdjacentHTML('beforeend', data.html);
          }
          if (!data.has_more) {
            const lessBtn = document.createElement('button');
            lessBtn.className = 'show-less-comments';
            lessBtn.dataset.postId = postId;
            lessBtn.textContent = 'Ver menos';
            btn.replaceWith(lessBtn);
            if (list) list.dataset.expanded = 'true';
          }
        });
    }
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.show-less-comments');
    if (btn) {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById('comments-' + postId);
      if (list) {
        Array.from(list.children).forEach((li, idx) => {
          if (idx >= 5) li.style.display = 'none';
        });
        list.dataset.expanded = 'false';
      }
      const moreBtn = document.createElement('button');
      moreBtn.className = 'show-more-comments';
      moreBtn.dataset.postId = postId;
      moreBtn.textContent = 'Ver más';
      btn.replaceWith(moreBtn);
    }
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.show-more-comments');
    if (btn) {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById('comments-' + postId);
      if (list) {
        Array.from(list.children).forEach(li => {
          li.style.display = '';
        });
        list.dataset.expanded = 'true';
      }
      const lessBtn = document.createElement('button');
      lessBtn.className = 'show-less-comments';
      lessBtn.dataset.postId = postId;
      lessBtn.textContent = 'Ver menos';
      btn.replaceWith(lessBtn);
    }
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.load-replies-btn');
    if (btn) {
      e.preventDefault();
      const commentId = btn.dataset.commentId;
      const list = document.getElementById('replies-' + commentId);
      if (list) list.classList.remove('d-none');
      const lessBtn = document.createElement('button');
      lessBtn.className = 'hide-replies-btn';
      lessBtn.dataset.commentId = commentId;
      lessBtn.textContent = 'Ver menos';
      btn.replaceWith(lessBtn);
    }
  });

  document.addEventListener('click', e => {
    const btn = e.target.closest('.hide-replies-btn');
    if (btn) {
      e.preventDefault();
      const commentId = btn.dataset.commentId;
      const list = document.getElementById('replies-' + commentId);
      if (list) list.classList.add('d-none');
      const moreBtn = document.createElement('button');
      moreBtn.className = 'load-replies-btn';
      moreBtn.dataset.commentId = commentId;
      moreBtn.textContent = 'Cargar respuestas';
      btn.replaceWith(moreBtn);
    }
  });

  // Submit new comments and replies via AJAX
  document.addEventListener('submit', e => {
    const commentForm = e.target.closest('.comment-form');
    const replyForm = e.target.closest('.reply-form');
    if (!commentForm && !replyForm) return;
    e.preventDefault();
    const form = commentForm || replyForm;
    const formData = new FormData(form);
    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRFToken': getCSRFToken()
      }
    })
      .then(res => res.json())
      .then(data => {
        if (!data.success) return;
        const countEl = document.querySelector(`.comment-count-wrapper[data-post-id='${data.post_id}'] .comment-count`);
        if (countEl) countEl.textContent = parseInt(countEl.textContent) + 1;
        if (commentForm) {
          let list = document.getElementById(`comments-${data.post_id}`);
          if (!list) {
            list = document.createElement('ul');
            list.id = `comments-${data.post_id}`;
            list.dataset.postId = data.post_id;
            list.dataset.expanded = 'true';
            list.className = 'list-group list-group-flush mt-2 comment-list';
            commentForm.insertAdjacentElement('afterend', list);
          }
          list.insertAdjacentHTML('beforeend', data.html);
          const input = commentForm.querySelector('.comment-input');
          if (input) input.value = '';

          const total = parseInt(countEl ? countEl.textContent : list.children.length);
          if (total > 5) {
            const postEl = commentForm.closest('.post');
            if (postEl) {
              const hasLess = postEl.querySelector('.show-less-comments');
              const hasMore = postEl.querySelector('.load-more-comments, .show-more-comments');
              if (!hasLess && !hasMore) {
                const lessBtn = document.createElement('button');
                lessBtn.className = 'show-less-comments';
                lessBtn.dataset.postId = data.post_id;
                lessBtn.textContent = 'Ver menos';
                list.insertAdjacentElement('afterend', lessBtn);
              }
            }
          }
        } else if (replyForm) {
          const li = replyForm.closest('li[data-comment-id]');
          if (!li) return;
          let list = li.querySelector('ul.replies-list');
          if (!list) {
            list = document.createElement('ul');
            list.id = `replies-${li.dataset.commentId}`;
            list.className = 'list-group mt-1 replies-list';
            li.appendChild(list);
          }
          list.classList.remove('d-none');
          list.insertAdjacentHTML('beforeend', data.html);
          const input = replyForm.querySelector('.comment-input');
          if (input) input.value = '';
          replyForm.classList.add('d-none');

          const container = replyForm.previousElementSibling;
          if (container) {
            const loadBtn = container.querySelector('.load-replies-btn');
            const hideBtn = container.querySelector('.hide-replies-btn');
            if (!hideBtn) {
              const newBtn = document.createElement('button');
              newBtn.className = 'hide-replies-btn';
              newBtn.dataset.commentId = li.dataset.commentId;
              newBtn.textContent = 'Ver menos';
              if (loadBtn) loadBtn.replaceWith(newBtn); else container.appendChild(newBtn);
            }
          }
        }
      });
  });

  window.addEventListener('scroll', () => {
    document.querySelectorAll('.comment-list').forEach(list => {
      if (list.dataset.expanded !== 'true') return;
      const post = list.closest('.post');
      if (!post) return;
      const rect = post.getBoundingClientRect();
      if (rect.bottom < 0 || rect.top > window.innerHeight) {
        Array.from(list.children).forEach((li, idx) => {
          if (idx >= 5) li.style.display = 'none';
        });
        list.dataset.expanded = 'false';
        const lessBtn = post.querySelector('.show-less-comments');
        if (lessBtn) {
          const moreBtn = document.createElement('button');
          moreBtn.className = 'show-more-comments';
          moreBtn.dataset.postId = lessBtn.dataset.postId;
          moreBtn.textContent = 'Ver más';
          lessBtn.replaceWith(moreBtn);
        }
      }
    });
  });
});
