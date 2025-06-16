document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.like-post').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      fetch(btn.dataset.url, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
        .then(res => res.json())
        .then(data => {
          const span = btn.querySelector('.like-count');
          if (span) span.textContent = data.likes;
          btn.classList.add('animate-pop');
          setTimeout(() => btn.classList.remove('animate-pop'), 300);
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
          btn.classList.add('animate-pop');
          setTimeout(() => btn.classList.remove('animate-pop'), 300);
        });
    });
  });

  document.querySelectorAll('.load-more-comments').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      const postId = btn.dataset.postId;
      const list = document.getElementById('comments-' + postId);
      const offset = list ? list.children.length : 0;
      fetch(`/post/${postId}/comments/?offset=${offset}&limit=10`, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
        .then(res => res.json())
        .then(data => {
          if (list) {
            list.insertAdjacentHTML('beforeend', data.html);
            list.querySelectorAll('.like-comment').forEach(newBtn => {
              newBtn.addEventListener('click', e => {
                e.preventDefault();
                fetch(newBtn.dataset.url, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
                  .then(res => res.json())
                  .then(likeData => {
                    const span = newBtn.querySelector('.like-count');
                    if (span) span.textContent = likeData.likes;
                    newBtn.classList.add('animate-pop');
                    setTimeout(() => newBtn.classList.remove('animate-pop'), 300);
                  });
              });
            });
          }
          if (!data.has_more) btn.remove();
        });
    });
  });
});
