// Functions from base.html

// Prefix URLs with the current language code extracted from the
// <html> tag. This ensures links and API calls automatically use
// the proper /es, /en, etc. prefix based on the active language.
const LANG_PREFIX = `/${document.documentElement.lang}`;

document
  .getElementById("searchFriendInput")
  ?.addEventListener("input", function () {
    const query = this.value.trim();
    const resultsList = document.getElementById("searchResults");
    resultsList.innerHTML = "";

    if (query.length === 0) {
      resultsList.style.display = "none";
      return;
    }

    fetch(`${LANG_PREFIX}/api/search-users/?q=${encodeURIComponent(query)}`)
      .then((res) => res.json())
      .then((users) => {
        users.forEach((user) => {
          const li = document.createElement("li");
          li.innerHTML = `
  <a href="${LANG_PREFIX}/profile/${user.username}/" class="user-suggestion-link">
    <div class="user-suggestion">
      <img src="${
        user.avatar || "https://via.placeholder.com/40"
      }" alt="avatar" />
      <span>${user.username}</span>
    </div>
  </a>
`;
          resultsList.appendChild(li);
        });

        // Mostrar u ocultar el contenedor según haya resultados o no
        if (users.length > 0) {
          resultsList.style.display = "block";
        } else {
          resultsList.style.display = "none";
        }
      });
  });

function getCSRFToken() {
  const cookie = document.cookie
    .split("; ")
    .find((row) => row.startsWith("csrftoken="));
  return cookie ? cookie.split("=")[1] : "";
}

function toggleNotifications(event) {
  event.preventDefault();
  const dropdown = document.getElementById("notificationDropdown");
  dropdown.style.display =
    dropdown.style.display === "block" ? "none" : "block";
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
  if (dropdown && !bell.contains(event.target)) {
    dropdown.style.display = "none";
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

document.querySelectorAll("#categoryTabs .nav-link").forEach((tab) => {
  tab.addEventListener("click", function (e) {
    e.preventDefault();
    const selected = this.getAttribute("data-category");
    document
      .querySelectorAll("#categoryTabs .nav-link")
      .forEach((link) => link.classList.remove("active"));
    document
      .querySelectorAll(".category-group")
      .forEach((group) => (group.style.display = "none"));
    const activeGroup = document.querySelector(
      `.category-group[data-category="${selected}"]`
    );
    if (activeGroup) activeGroup.style.display = "flex";
  });
});
