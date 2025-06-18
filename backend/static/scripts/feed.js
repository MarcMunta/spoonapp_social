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
    if (/\.(mp4|webm|ogg)$/i.test(url)) {
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
    currentExpires = el.dataset.expires.split('|');
    currentStoryIds = el.dataset.storyId.split('|');
    currentIndex = 0;
    currentStoryElIndex = idx;
    currentIsOwn = el.dataset.user === currentUsername;
    const userContainer = document.querySelector('.story-modal-user');
    if (userContainer) {
      userContainer.innerHTML = `<img src="${el.dataset.avatarUrl}" class="story-modal-avatar me-2" width="40" height="40">` +
        `<a href="${el.dataset.profileUrl}" class="story-modal-name text-white fs-5">${el.dataset.user}</a>`;
    }
    const replyBtn = document.getElementById('storyReplySend');
    if (replyBtn) {
      replyBtn.dataset.storyId = currentIsOwn ? '' : currentStoryIds[currentIndex];
      replyBtn.disabled = currentIsOwn;
    }
    if (replyInput) replyInput.disabled = currentIsOwn;
    if (storyOptions) storyOptions.style.display = currentIsOwn ? 'block' : 'none';
    if (storyViews) storyViews.style.display = currentIsOwn ? 'block' : 'none';
    if (replyContainer) replyContainer.style.display = currentIsOwn ? 'none' : 'flex';
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
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })
        .then(res => res.json())
        .then(data => {
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

  if (deleteBtn) {
    deleteBtn.addEventListener('click', e => {
      e.preventDefault();
      const storyId = deleteBtn.dataset.storyId;
      if (!storyId) return;
      if (!confirm('¿Eliminar definitivamente esta historia?')) {
        resumeProgress();
        return;
      }
      fetch(`/story/${storyId}/delete/`, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'X-CSRFToken': getCSRFToken() }
      }).then(res => res.json()).then(data => {
        if (data.success) {
          window.location.reload();
        }
      });
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
