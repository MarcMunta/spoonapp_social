document.addEventListener('DOMContentLoaded', () => {
  const searchInput = document.getElementById('userSearchInput');
  const container = document.getElementById('userCardsContainer');
  const initialHtml = container.innerHTML;
  const LANG_PREFIX = window.LANG_PREFIX || `/${document.documentElement.lang}`;
  const DEFAULT_AVATAR = window.DEFAULT_AVATAR || '';

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  function applyAnimations() {
    const cards = Array.from(container.querySelectorAll('.user-card'));
    cards.forEach((card, idx) => {
      card.style.setProperty('--delay', `${idx * 50}ms`);
      observer.observe(card);
    });
  }

  function renderCards(users) {
    if (!users.length) {
      container.innerHTML = '<p>No users available.</p>';
      return;
    }
    container.innerHTML = '';
    users.forEach(u => {
      const col = document.createElement('div');
      col.className = 'col-6 col-md-4 col-lg-2 mb-4';
      const cleanStatus = u.status || '';
      const statusHtml = cleanStatus ? `<p class="card-text text-muted small">${cleanStatus}</p>` : '';
      col.innerHTML = `
        <div class="card user-card text-center h-100" style="--profile-color:${u.bubble_color}">
          <img src="${u.avatar || DEFAULT_AVATAR}" class="card-img-top mx-auto mt-3 user-avatar" alt="${u.username}">
          <div class="card-body p-2">
            <h5 class="card-title mb-1">${u.username}</h5>
            ${statusHtml}
          </div>
        </div>`;
      container.appendChild(col);
    });
    applyAnimations();
  }

  searchInput.addEventListener('input', () => {
    const q = searchInput.value.trim();
    if (!q) {
      container.innerHTML = initialHtml;
      applyAnimations();
      return;
    }
    fetch(`${LANG_PREFIX}/api/search-users/?q=${encodeURIComponent(q)}&limit=12`)
      .then(res => res.json())
      .then(data => renderCards(data.results));
  });

  applyAnimations();
});
