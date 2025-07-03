export function initialize() {
  const root = document.getElementById('app');
  if (root) {
    root.innerHTML = '<p>Frontend bundle loaded via ESM!</p>';
  }
}

if (typeof window !== 'undefined') {
  window.addEventListener('DOMContentLoaded', initialize);
}
