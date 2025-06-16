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
          if (!data.has_more) btn.remove();
        });
    }
  });
});
