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
  }

  let currentUrls = [];
  let currentExpires = [];
  let currentIndex = 0;
  let progressTimeout;
  let countdownInterval;

  const modal = document.getElementById('storyModal');
  const img = document.getElementById('storyImage');
  const video = document.getElementById('storyVideo');
  const progressBar = document.querySelector('.story-progress-bar');
  const modalContent = modal.querySelector('.story-modal-content');

  const countdownEl = document.querySelector('.story-countdown');

  function updateCountdown(expireIso) {
    if (!countdownEl) return;
    const diff = new Date(expireIso) - Date.now();
    if (diff <= 0) {
      countdownEl.textContent = '0m';
      return;
    }
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    countdownEl.textContent = `${hours}h ${mins}m`;
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
    clearTimeout(progressTimeout);
    clearInterval(countdownInterval);
    updateCountdown(currentExpires[idx]);
    countdownInterval = setInterval(() => updateCountdown(currentExpires[idx]), 1000);
    progressTimeout = setTimeout(nextStory, 5000);
  }

  function openStories(urls, expires, user) {
    currentUrls = urls;
    currentExpires = expires;
    currentIndex = 0;
    document.querySelector('.story-modal-user').textContent = user;
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
      closeStories();
    }
  }

  function prevStory() {
    if (currentIndex > 0) {
      currentIndex--;
      showStory(currentIndex);
    }
  }

  document.querySelectorAll('.open-story').forEach(el => {
    el.addEventListener('click', () => {
      const urls = el.dataset.urls.split('|');
      const expires = el.dataset.expires.split('|');
      const user = el.dataset.user;
      openStories(urls, expires, user);
    });
  });

  document.querySelector('.story-next')?.addEventListener('click', nextStory);
  document.querySelector('.story-prev')?.addEventListener('click', prevStory);
  document.querySelector('.story-modal-close')?.addEventListener('click', closeStories);

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
