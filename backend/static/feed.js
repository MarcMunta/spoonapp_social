document.addEventListener('DOMContentLoaded', () => {
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
