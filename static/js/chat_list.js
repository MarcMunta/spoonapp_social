function initChatList() {
  const items = document.querySelectorAll('.spoon-chat-item');
  if (!items.length) return;
  items.forEach((item, idx) => {
    item.style.opacity = '0';
    item.style.transform = 'translateY(100vh)';
    item.style.animationDelay = `${idx * 0.1}s`;
    item.addEventListener(
      'animationend',
      (e) => {
        if (e.animationName === 'chatBounce') {
          item.classList.add('chat-glow');
          item.removeAttribute('style');
        }
      },
      { once: true }
    );
  });
  requestAnimationFrame(() => {
    items.forEach((item) => {
      item.classList.remove('chat-bounce', 'chat-glow');
      void item.offsetWidth; // trigger reflow
      item.classList.add('chat-bounce');
    });
  });
}

document.addEventListener('DOMContentLoaded', initChatList);
