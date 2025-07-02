document.addEventListener('DOMContentLoaded', () => {
  const body = document.body;
  if (!body.classList.contains('home-page')) return;

  const posts = document.querySelectorAll('.post');
  posts.forEach((post, index) => {
    post.style.setProperty('--delay', `${index * 100}ms`);
  });

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('post-visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  posts.forEach(post => observer.observe(post));
});
