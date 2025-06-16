Document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.like-post').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      fetch(btn.dataset.url, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
        .then(res => res.json())
        .then(data => {
          const span = btn.querySelector('.like-count');
          if (span) span.textContent = data.likes;
        });
    });
  });

  document.querySelectorAll('.like-comment').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      fetch(btn.dataset.url, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
        .then(res => res.json())
        .then(data => {
          const span = btn.querySelector('.like-count');
          if (span) span.textContent = data.likes;
        });
    });
  });

  document.querySelectorAll('.comment-toggle').forEach(icon => {
    icon.addEventListener('click', () => {
      const container = document.getElementById('comments-' + icon.dataset.postId);
      if (container) {
        container.querySelectorAll('.extra-comment').forEach(c => c.classList.toggle('extra-comment'));
      }
    });
  });
});
