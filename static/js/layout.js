// Functions from base.html

// Prefix URLs with the current language code extracted from the
// <html> tag. Reuse the global variable if already defined to avoid
// redeclaration errors when multiple scripts are loaded.
if (!window.LANG_PREFIX) {
  window.LANG_PREFIX = `/${document.documentElement.lang}`;
}

function onReady(fn) {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", fn);
  } else {
    fn();
  }
}

const searchInput = document.getElementById("searchFriendInput");
if (searchInput) {
  const updateFriendSuggestions = () => {
    const query = searchInput.value.trim();
    const resultsList = document.getElementById("searchResults");
    if (!query) {
      resultsList.innerHTML = "";
      resultsList.style.display = "none";
      return;
    }

    fetch(`${LANG_PREFIX}/api/search-users/?q=${encodeURIComponent(query)}`)
      .then((res) => res.json())
      .then((users) => {
        resultsList.innerHTML = "";
        users.slice(0, 3).forEach((user) => {
          const li = document.createElement("li");
          li.innerHTML = `
  <a href="${LANG_PREFIX}/profile/${user.username}/" class="user-suggestion-link">
    <div class="user-suggestion">
      <img src="${user.avatar || "https://via.placeholder.com/40"}" alt="avatar" />
      <span>${user.username}</span>
    </div>
  </a>
`;
          resultsList.appendChild(li);
        });

        if (users.length > 0) {
          resultsList.style.display = "block";
        } else {
          resultsList.style.display = "none";
        }
      });
  };

  searchInput.addEventListener("input", updateFriendSuggestions);
}

const searchCommunityInput = document.getElementById("searchCommunityInput");
if (searchCommunityInput) {
  const updateCommunitySuggestions = () => {
    const query = searchCommunityInput.value.trim();
    const resultsList = document.getElementById("searchCommunityResults");
    if (!query) {
      resultsList.innerHTML = "";
      resultsList.style.display = "none";
      return;
    }

    fetch(`${LANG_PREFIX}/api/search-communities/?q=${encodeURIComponent(query)}`)
      .then((res) => res.json())
      .then((communities) => {
        resultsList.innerHTML = "";
        communities.slice(0, 3).forEach((comm) => {
          const li = document.createElement("li");
          li.innerHTML = `
  <a href="${LANG_PREFIX}/profile/${comm.username}/" class="user-suggestion-link">
    <div class="user-suggestion">
      <img src="${comm.avatar || "https://via.placeholder.com/40"}" alt="avatar" />
      <span>${comm.username}</span>
    </div>
  </a>
`;
          resultsList.appendChild(li);
        });

        if (communities.length > 0) {
          resultsList.style.display = "block";
        } else {
          resultsList.style.display = "none";
        }
      });
  };

  searchCommunityInput.addEventListener("input", updateCommunitySuggestions);
}

function getCSRFToken() {
  const cookie = document.cookie
    .split("; ")
    .find((row) => row.startsWith("csrftoken="));
  return cookie ? cookie.split("=")[1] : "";
}

function buildLangUrl(url, lang) {
  try {
    const u = new URL(url, window.location.origin);
    const prefixPattern = /^\/(?:en|es)(?=\/|$)/;
    u.pathname = u.pathname.replace(prefixPattern, "");
    if (!u.pathname.startsWith("/")) u.pathname = "/" + u.pathname;
    u.pathname = `/${lang}${u.pathname}`;
    return u.pathname + u.search + u.hash;
  } catch (e) {
    return url;
  }
}

onReady(() => {
  document
    .querySelectorAll("form.language-form select[name='language']")
    .forEach((select) => {
      select.addEventListener("change", () => {
        const form = select.closest("form");
        const data = new FormData(form);
        const lang = data.get("language");
        const nextUrl = data.get("next") || window.location.href;
        const redirectUrl = buildLangUrl(nextUrl, lang);
        data.set("next", redirectUrl);
        fetch(form.action, {
          method: "POST",
          headers: { "X-CSRFToken": getCSRFToken() },
          body: data,
        }).then(() => {
          window.location.href = redirectUrl;
        });
      });
    });
});

function toggleNotifications(event) {
  event.preventDefault();
  const dropdown = document.getElementById("notificationDropdown");
  if (!dropdown) return;

  if (dropdown.classList.contains("show")) {
    dropdown.classList.remove("show");
    dropdown.classList.add("hide");
    dropdown.addEventListener(
      "animationend",
      function handler() {
        dropdown.style.display = "none";
        dropdown.classList.remove("hide");
        dropdown.removeEventListener("animationend", handler);
      },
      { once: true }
    );
  } else {
    dropdown.style.display = "block";
    // trigger reflow to restart animation
    dropdown.offsetHeight;
    dropdown.classList.add("show");
  }
}

function markAsRead(notificationId) {
  fetch(`${LANG_PREFIX}/mark-notification-read/${notificationId}/`, {
    method: "POST",
    headers: {
      "X-CSRFToken": getCSRFToken(),
      "X-Requested-With": "XMLHttpRequest",
    },
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        const notificationItem = document.querySelector(
          `[data-id="${notificationId}"]`
        );
        if (notificationItem) {
          notificationItem.remove();
        }
        const badge = document.getElementById("notificationBadge");
        if (badge) {
          const newCount = data.unread_count;
          if (newCount > 0) {
            badge.textContent = newCount;
          } else {
            badge.style.display = "none";
          }
        }
      }
    });
}

setInterval(() => {
  if (document.querySelector(".notification-bell")) {
    fetch(`${LANG_PREFIX}/api/notifications-count/`, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => response.json())
      .then((data) => {
        const badge = document.getElementById("notificationBadge");
        if (data.unread_count > 0) {
          if (badge) {
            badge.textContent = data.unread_count;
            badge.style.display = "inline";
          }
        } else if (badge) {
          badge.style.display = "none";
        }
      });
  }
}, 30000);

document.addEventListener("click", function (event) {
  const dropdown = document.getElementById("notificationDropdown");
  const bell = document.querySelector(".notification-bell");
  if (dropdown && !bell.contains(event.target) && dropdown.classList.contains("show")) {
    dropdown.classList.remove("show");
    dropdown.classList.add("hide");
    dropdown.addEventListener(
      "animationend",
      function handler() {
        dropdown.style.display = "none";
        dropdown.classList.remove("hide");
        dropdown.removeEventListener("animationend", handler);
      },
      { once: true }
    );
  }
});

function switchTab(tab) {
  document
    .querySelectorAll(".tab-button")
    .forEach((btn) => btn.classList.remove("active"));
  document
    .querySelectorAll(".tab-content")
    .forEach((div) => (div.style.display = "none"));
  document.getElementById("tab-" + tab).style.display = "block";
  event.target.classList.add("active");
}

const notificationBadge = document.getElementById("notificationBadge");
if (notificationBadge) {
  notificationBadge.style.cssText = `
        position: absolute;
        top: -10px;
        right: -10px;
        background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        color: white;
        border-radius: 50%;
        min-width: 22px;
        height: 22px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        font-weight: 700;
        border: 2px solid white;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
        animation: notification-pulse 2s infinite;
        z-index: 10;
      `;
}

const style = document.createElement("style");
style.textContent = `
      @keyframes notification-pulse {
        0%, 100% {
          transform: scale(1);
          box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
        }
        50% {
          transform: scale(1.1);
          box-shadow: 0 6px 16px rgba(239, 68, 68, 0.6);
        }
      }
      .notification-item[data-notification-type="message"] {
        cursor: pointer;
        transition: background-color 0.3s ease;
      }
      .notification-item[data-notification-type="message"]:hover {
        background-color: #f0f9ff;
      }
    `;
document.head.appendChild(style);

document.addEventListener("click", function (e) {
  const notificationItem = e.target.closest(
    '.notification-item[data-notification-type="message"]'
  );
  if (notificationItem && notificationItem.hasAttribute("data-chat-url")) {
    const chatUrl = notificationItem.getAttribute("data-chat-url");
    if (chatUrl) {
      const notificationId = notificationItem.getAttribute("data-id");
      markAsRead(notificationId);
      window.location.href = chatUrl;
    }
  }
});

document
  .getElementById("id_profile_picture")
  ?.addEventListener("change", function () {
    document.getElementById("photoUploadForm").submit();
  });

onReady(() => {
  const tabsContainer = document.getElementById("categoryTabs");
  if (!tabsContainer) return;

  tabsContainer.addEventListener("click", (e) => {
    const tab = e.target.closest(".nav-link[data-category]");
    if (!tab) return;

    e.preventDefault();
    const selected = tab.getAttribute("data-category");

    tabsContainer
      .querySelectorAll(".nav-link")
      .forEach((link) => link.classList.remove("active"));
    tab.classList.add("active");

  document.querySelectorAll(".category-group").forEach((group) => {
      group.style.display =
        group.getAttribute("data-category") === selected ? "flex" : "none";
  });
  });
});

function animateTopMenuIcons() {
  const container = document.querySelector('.topbar-icons');
  if (!container) return;
  const icons = [];
  container.childNodes.forEach((node) => {
    if (node.nodeType !== 1) return;
    if (node.matches('a, span')) {
      icons.push(node);
    } else {
      const bell = node.querySelector('.notification-bell');
      if (bell) icons.push(bell);
    }
  });
  icons.forEach((icon, idx) => {
    icon.style.opacity = '0';
    icon.style.animationDelay = `${idx * 0.12}s`;
    icon.addEventListener(
      'animationend',
      (e) => {
        if (e.animationName === 'menuIconBounce') {
          icon.classList.add('menu-icon-glow');
          icon.removeAttribute('style');
        }
      },
      { once: true }
    );
    setTimeout(() => {
      icon.removeAttribute('style');
    }, 1200);
  });
  requestAnimationFrame(() => {
    icons.forEach((icon) => {
      icon.classList.remove('menu-icon-bounce', 'menu-icon-glow');
      void icon.offsetWidth;
      icon.classList.add('menu-icon-bounce');
    });
  });
}

onReady(animateTopMenuIcons);


function animateFriendBubbles() {
  const container = document.querySelector(".friends-bubbles");
  if (!container) return;
  const bubbles = container.querySelectorAll(".friend-bubble, .show-more-users");
  bubbles.forEach((bubble, idx) => {
    bubble.style.opacity = "0";
    bubble.style.transform = "translateY(50px)";
    bubble.style.animationDelay = `${idx * 0.1}s`;
    bubble.addEventListener(
      "animationend",
      (e) => {
        if (e.animationName === "friendBounce") {
          bubble.classList.add("friend-glow");
          bubble.removeAttribute("style");
        }
      },
      { once: true }
    );
  });
  requestAnimationFrame(() => {
    bubbles.forEach((bubble) => {
      bubble.classList.remove("friend-bounce", "friend-glow");
      void bubble.offsetWidth;
      bubble.classList.add("friend-bounce");
    });
  });
}

onReady(animateFriendBubbles);
onReady(applyUserListLimit);

function applyUserListLimit() {
  const container = document.querySelector(".friends-bubbles");
  if (!container) return;
  const bubbles = container.querySelectorAll(".friend-bubble");
  const moreBtn = container.querySelector(".show-more-users");
  const lessBtn = container.querySelector(".show-less-users");
  if (bubbles.length <= 3) {
    if (moreBtn) moreBtn.style.display = "none";
    if (lessBtn) lessBtn.style.display = "none";
    return;
  }
  bubbles.forEach((b, idx) => {
    b.style.display = idx < 3 ? "" : "none";
  });
  if (moreBtn) moreBtn.style.display = "";
  if (lessBtn) lessBtn.style.display = "none";
}

function updateFriendsList() {
  const container = document.querySelector(".friends-bubbles");
  if (!container) return;
  fetch(`${LANG_PREFIX}/api/friends/`, {
    headers: { "X-Requested-With": "XMLHttpRequest" },
  })
    .then((res) => res.json())
    .then((data) => {
      container.innerHTML = data.html;
      animateFriendBubbles();
      applyUserListLimit();
    });
}

onReady(() => {
  updateFriendsList();
  setInterval(updateFriendsList, 30000);
});

onReady(() => {
  document.addEventListener("click", (e) => {
    const moreBtn = e.target.closest(".show-more-users");
    if (moreBtn) {
      e.preventDefault();
      const container = moreBtn.closest(".friends-bubbles");
      if (container) {
        container.querySelectorAll(".friend-bubble").forEach((b) => {
          b.style.display = "";
        });
        moreBtn.classList.add("d-none");
        const lessBtn = container.querySelector(".show-less-users");
        if (lessBtn) lessBtn.classList.remove("d-none");
      }
    }
    const lessBtn = e.target.closest(".show-less-users");
    if (lessBtn) {
      e.preventDefault();
      applyUserListLimit();
    }
  });
});

onReady(() => {
  const btn = document.getElementById('menuToggle');
  const sidebar = document.querySelector('.sidebar');
  if (!btn || !sidebar) return;
  const icon = btn.querySelector('i');

  function animateSidebarItems() {
    const items = sidebar.querySelectorAll('.menu-item, .restaurants-section > *');
    items.forEach((el, idx) => {
      el.style.opacity = '0';
      el.style.transform = 'translateX(-20px)';
      el.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
      el.style.transitionDelay = `${idx * 50}ms`;
    });
    requestAnimationFrame(() => {
      items.forEach((el) => {
        el.style.opacity = '1';
        el.style.transform = 'translateX(0)';
      });
    });
  }

  btn.addEventListener('click', () => {
    const hidden = document.body.classList.toggle('sidebar-hidden');
    if (icon) {
      icon.className = hidden ? 'fas fa-bars' : 'fas fa-times';
    }
    if (!hidden) animateSidebarItems();
  });
});
