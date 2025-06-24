document.addEventListener("DOMContentLoaded", function () {
  const messagesArea = document.getElementById("spoon-messages-area");
  const messageForm = document.getElementById("spoon-message-form");
  const messageInput = document.getElementById("spoon-message-input");
  const emojiBtn = document.getElementById("emoji-btn");
  const emojiPicker = document.getElementById("emoji-picker");
  const scrollTopIndicator = document.getElementById("scroll-top-indicator");
  const scrollBottomIndicator = document.getElementById(
    "scroll-bottom-indicator"
  );

  let isLoadingMessages = false;
  let hasMoreMessages = true;
  let hasNewerMessages = false;
  let oldestMessageId = null;
  let newestMessageId = null;
  let initialLoad = true;
  const chatId = messagesArea ? messagesArea.dataset.chatId : null;
  let isUserScrolling = false;
  let scrollTimer = null;

  const blockedWords = ["cola", "gay", "puta"];
  function isValidMessage(msg) {
    if (!msg || msg.trim().length < 3) return false;
    const text = msg.toLowerCase();
    return !blockedWords.some((w) => text.includes(w));
  }

  console.log("🚀 Chat system initializing...");

  // Assicura che l'area input sia sempre visibile
  function ensureInputAreaVisible() {
    const inputArea = document.querySelector(".spoon-input-area");
    if (inputArea) {
      inputArea.style.cssText += `
                position: fixed !important;
                bottom: 0 !important;
                left: 240px !important;
                right: 0 !important;
                z-index: 1000 !important;
                background: linear-gradient(135deg, #ffffff 0%, #f7fafc 100%) !important;
                border-top: 3px solid #e2e8f0 !important;
                box-shadow: 0 -4px 15px rgba(0, 0, 0, 0.08) !important;
                margin: 0 !important;
                padding: 18px 20px !important;
            `;
      console.log("✅ Input area fixed to bottom");
    }
  }

  // Assicura che l'area messaggi abbia l'altezza corretta
  function ensureMessagesAreaHeight() {
    if (messagesArea) {
      messagesArea.style.cssText += `
                height: calc(100vh - 240px) !important;
                overflow-y: auto !important;
                overflow-x: hidden !important;
                padding: 20px 20px 120px !important;
                scroll-behavior: smooth !important;
            `;
      console.log("✅ Messages area height set correctly");
    }
  }

  // Applica le correzioni
  ensureInputAreaVisible();
  ensureMessagesAreaHeight();

  // Funzione per ottenere il token CSRF
  function getCSRFToken() {
    const cookie = document.cookie
      .split("; ")
      .find((row) => row.startsWith("csrftoken="));
    return cookie ? cookie.split("=")[1] : "";
  }

  // Initialize message IDs from existing messages
  function initializeMessageIds() {
    const messageElements = messagesArea.querySelectorAll("[data-message-id]");
    if (messageElements.length > 0) {
      oldestMessageId = messageElements[0].dataset.messageId;
      newestMessageId =
        messageElements[messageElements.length - 1].dataset.messageId;
    }
    console.log("📨 Initialized message IDs:", {
      oldestMessageId,
      newestMessageId,
      total: messageElements.length,
    });
  }

  initializeMessageIds();

  // Enhanced scroll indicators
  function updateScrollIndicators() {
    if (!messagesArea) return;

    const scrollTop = messagesArea.scrollTop;
    const scrollHeight = messagesArea.scrollHeight;
    const clientHeight = messagesArea.clientHeight;
    const scrollBottom = scrollHeight - scrollTop - clientHeight;

    // Show top indicator if we can scroll up and have more messages
    const showTopIndicator =
      scrollTop > 100 && hasMoreMessages && !isLoadingMessages;
    if (scrollTopIndicator) {
      scrollTopIndicator.style.display = showTopIndicator ? "flex" : "none";
    }

    // Show bottom indicator if we can scroll down and have newer messages
    const showBottomIndicator =
      scrollBottom > 100 && hasNewerMessages && !isLoadingMessages;
    if (scrollBottomIndicator) {
      scrollBottomIndicator.style.display = showBottomIndicator
        ? "flex"
        : "none";
    }

    console.log("📊 Scroll indicators updated:", {
      scrollTop,
      scrollBottom,
      hasMoreMessages,
      hasNewerMessages,
      showTopIndicator,
      showBottomIndicator,
    });
  }

  // Enhanced smooth scrolling
  function scrollToBottom(force = false) {
    if (messagesArea && (!isUserScrolling || force)) {
      messagesArea.scrollTo({
        top: messagesArea.scrollHeight,
        behavior: initialLoad ? "auto" : "smooth",
      });
      initialLoad = false;
      hasNewerMessages = false;
      updateScrollIndicators();
      console.log("⬇️ Scrolled to bottom");
    }
  }

  function scrollToTop() {
    if (messagesArea) {
      messagesArea.scrollTo({
        top: 0,
        behavior: "smooth",
      });
      console.log("⬆️ Scrolled to top");
    }
  }

  // Scroll to bottom on initial load
  setTimeout(() => {
    scrollToBottom(true);
    console.log("🎯 Initial scroll to bottom completed");
  }, 500);

  // Enhanced mouse wheel scrolling con throttling migliorato
  let wheelTimeout;
  if (messagesArea) {
    messagesArea.addEventListener(
      "wheel",
      function (e) {
        isUserScrolling = true;
        clearTimeout(scrollTimer);
        clearTimeout(wheelTimeout);

        const scrollTop = this.scrollTop;
        const scrollHeight = this.scrollHeight;
        const clientHeight = this.clientHeight;
        const delta = e.deltaY;

        console.log("🎡 Wheel event:", {
          scrollTop,
          delta,
          hasMoreMessages,
          hasNewerMessages,
        });

        // Throttle wheel events per migliori performance
        wheelTimeout = setTimeout(() => {
          // Auto-load when near boundaries
          if (
            scrollTop <= 150 &&
            delta < 0 &&
            hasMoreMessages &&
            !isLoadingMessages
          ) {
            console.log("🔄 Triggering load older messages from wheel");
            loadOlderMessages();
          }

          if (
            scrollTop + clientHeight >= scrollHeight - 150 &&
            delta > 0 &&
            hasNewerMessages &&
            !isLoadingMessages
          ) {
            console.log("🔄 Triggering load newer messages from wheel");
            loadNewerMessages();
          }
        }, 100);

        scrollTimer = setTimeout(() => {
          isUserScrolling = false;
          console.log("🛑 User stopped scrolling");
        }, 1500);

        updateScrollIndicators();
      },
      { passive: true }
    );
  }

  // Enhanced scroll event handling con debouncing
  let scrollTimeout;
  if (messagesArea) {
    messagesArea.addEventListener("scroll", function () {
      clearTimeout(scrollTimeout);

      scrollTimeout = setTimeout(() => {
        const scrollTop = this.scrollTop;
        const scrollHeight = this.scrollHeight;
        const clientHeight = this.clientHeight;

        console.log("📜 Scroll event:", {
          scrollTop,
          scrollHeight,
          clientHeight,
        });

        // Auto-load older messages when scrolled to top
        if (scrollTop <= 100 && hasMoreMessages && !isLoadingMessages) {
          console.log("📤 Auto-loading older messages");
          loadOlderMessages();
        }

        // Auto-load newer messages when scrolled to bottom
        if (
          scrollTop + clientHeight >= scrollHeight - 100 &&
          hasNewerMessages &&
          !isLoadingMessages
        ) {
          console.log("📥 Auto-loading newer messages");
          loadNewerMessages();
        }

        updateScrollIndicators();
      }, 150);
    });
  }

  // Click handlers for scroll indicators
  if (scrollTopIndicator) {
    scrollTopIndicator.addEventListener("click", function () {
      console.log("🔝 Top indicator clicked");
      if (hasMoreMessages) {
        loadOlderMessages();
      } else {
        scrollToTop();
      }
    });
  }

  if (scrollBottomIndicator) {
    scrollBottomIndicator.addEventListener("click", function () {
      console.log("🔻 Bottom indicator clicked");
      if (hasNewerMessages) {
        loadNewerMessages();
      } else {
        scrollToBottom(true);
      }
    });
  }

  // Load older messages function con logging migliorato
  function loadOlderMessages() {
    if (isLoadingMessages || !hasMoreMessages || !oldestMessageId) {
      console.log("❌ Cannot load older messages:", {
        isLoadingMessages,
        hasMoreMessages,
        oldestMessageId,
      });
      return;
    }

    isLoadingMessages = true;
    console.log("📤 Loading older messages before ID:", oldestMessageId);
    updateScrollIndicators();

    // Show loading indicator
    const loadingDiv = document.createElement("div");
    loadingDiv.className = "spoon-loading-messages";
    loadingDiv.id = "loading-older-messages";
    loadingDiv.innerHTML = `
            <div class="spoon-typing-indicator">
                <div class="spoon-typing-dot"></div>
                <div class="spoon-typing-dot"></div>
                <div class="spoon-typing-dot"></div>
                <small class="ms-2 text-muted">Loading older messages...</small>
            </div>
        `;
    messagesArea.insertBefore(loadingDiv, messagesArea.firstChild);

    const url = `/chat/${chatId}/messages/?before=${oldestMessageId}&limit=20`;
    console.log("🌐 Fetching URL:", url);

    fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => {
        console.log("📡 Response status:", response.status);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
      })
      .then((data) => {
        console.log("📦 Loaded older messages:", data);

        // Remove loading indicator
        const loadingIndicator = document.getElementById(
          "loading-older-messages"
        );
        if (loadingIndicator) {
          loadingIndicator.remove();
        }

        if (data.messages && data.messages.length > 0) {
          const scrollHeight = messagesArea.scrollHeight;
          const scrollTop = messagesArea.scrollTop;

          // Add new messages to the top in reverse order
          const messagesToAdd = [...data.messages].reverse();
          messagesToAdd.forEach((msg) => {
            const messageWrapper = document.createElement("div");
            messageWrapper.className = `d-flex ${
              msg.is_mine ? "justify-content-end" : ""
            } mb-3`;
            messageWrapper.dataset.messageId = msg.id;
            messageWrapper.innerHTML = `
                        <div class="chat-bubble ${
                          msg.is_mine ? "user" : "other"
                        } spoon-message-loaded">
                            <div>${escapeHtml(msg.content)}</div>
                            <span class="timestamp">${msg.sent_at}</span>
                        </div>
                    `;
            messagesArea.insertBefore(messageWrapper, messagesArea.firstChild);
          });

          // Update oldest message ID
          oldestMessageId = data.messages[0].id;
          hasMoreMessages = data.has_more;
          console.log(
            "✅ Updated oldestMessageId:",
            oldestMessageId,
            "hasMoreMessages:",
            hasMoreMessages
          );

          // Maintain scroll position
          const newScrollHeight = messagesArea.scrollHeight;
          messagesArea.scrollTop = scrollTop + (newScrollHeight - scrollHeight);

          // Add fade-in animation to new messages
          setTimeout(() => {
            messagesArea
              .querySelectorAll(".spoon-message-loaded")
              .forEach((msg) => {
                msg.classList.remove("spoon-message-loaded");
              });
          }, 100);
        } else {
          hasMoreMessages = false;
          console.log("🚫 No more older messages available");
        }

        isLoadingMessages = false;
        updateScrollIndicators();
      })
      .catch((error) => {
        console.error("💥 Error loading older messages:", error);
        const loadingIndicator = document.getElementById(
          "loading-older-messages"
        );
        if (loadingIndicator) {
          loadingIndicator.remove();
        }
        isLoadingMessages = false;
        updateScrollIndicators();
        showErrorMessage("Failed to load older messages. Please try again.");
      });
  }

  // Load newer messages function con logging migliorato
  function loadNewerMessages() {
    if (isLoadingMessages || !newestMessageId) {
      console.log("❌ Cannot load newer messages:", {
        isLoadingMessages,
        newestMessageId,
      });
      return;
    }

    isLoadingMessages = true;
    console.log("📥 Loading newer messages after ID:", newestMessageId);
    updateScrollIndicators();

    const url = `/chat/${chatId}/messages/?after=${newestMessageId}&limit=20`;
    console.log("🌐 Fetching URL:", url);

    fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => {
        console.log("📡 Response status:", response.status);
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
      })
      .then((data) => {
        console.log("📦 Loaded newer messages:", data);

        if (data.messages && data.messages.length > 0) {
          // Add new messages to the bottom
          data.messages.forEach((msg) => {
            const messageWrapper = document.createElement("div");
            messageWrapper.className = `d-flex ${
              msg.is_mine ? "justify-content-end" : ""
            } mb-3`;
            messageWrapper.dataset.messageId = msg.id;
            messageWrapper.innerHTML = `
                        <div class="chat-bubble ${
                          msg.is_mine ? "user" : "other"
                        }" data-new="true">
                            <div>${escapeHtml(msg.content)}</div>
                            <span class="timestamp">${msg.sent_at}</span>
                        </div>
                    `;
            messagesArea.appendChild(messageWrapper);
          });

          // Update newest message ID
          newestMessageId = data.messages[data.messages.length - 1].id;
          hasNewerMessages = data.has_more || false;
          console.log(
            "✅ Updated newestMessageId:",
            newestMessageId,
            "hasNewerMessages:",
            hasNewerMessages
          );
        } else {
          hasNewerMessages = false;
          console.log("🚫 No newer messages available");
        }

        isLoadingMessages = false;
        updateScrollIndicators();
      })
      .catch((error) => {
        console.error("💥 Error loading newer messages:", error);
        isLoadingMessages = false;
        updateScrollIndicators();
      });
  }

  // Enhanced floating scroll button
  let scrollFloatingBtn = null;

  function updateFloatingScrollButton() {
    if (!messagesArea) return;

    const scrollTop = messagesArea.scrollTop;
    const scrollHeight = messagesArea.scrollHeight;
    const clientHeight = messagesArea.clientHeight;
    const isScrolledUp = scrollTop < scrollHeight - clientHeight - 200;

    if (isScrolledUp && !scrollFloatingBtn) {
      scrollFloatingBtn = document.createElement("button");
      scrollFloatingBtn.className = "spoon-floating-scroll-btn";
      scrollFloatingBtn.innerHTML = `
                <i class="fas fa-arrow-down"></i>
                <span class="spoon-scroll-label">Latest</span>
            `;
      scrollFloatingBtn.title = "Scroll to latest messages";
      scrollFloatingBtn.onclick = () => scrollToBottom(true);
      document.body.appendChild(scrollFloatingBtn);
      console.log("🎈 Floating scroll button added");
    } else if (!isScrolledUp && scrollFloatingBtn) {
      scrollFloatingBtn.remove();
      scrollFloatingBtn = null;
      console.log("🎈 Floating scroll button removed");
    }
  }

  // Update floating button on scroll
  if (messagesArea) {
    messagesArea.addEventListener("scroll", updateFloatingScrollButton);
  }

  // FIXED: Enhanced emoji picker functionality - risolve il bug della scomparsa
  if (emojiBtn && emojiPicker) {
    emojiBtn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      const isVisible = emojiPicker.classList.contains("show");
      emojiPicker.classList.toggle("show", !isVisible);
      console.log("😊 Emoji picker toggled:", !isVisible);
    });

    // Close picker when clicking outside
    document.addEventListener("click", function (e) {
      if (
        emojiPicker &&
        !emojiBtn.contains(e.target) &&
        !emojiPicker.contains(e.target)
      ) {
        emojiPicker.classList.remove("show");
        console.log("😊 Emoji picker closed - clicked outside");
      }
    });

    // Handle emoji selection
    emojiPicker.addEventListener("click", function (e) {
      if (e.target.classList.contains("emoji-item")) {
        e.preventDefault();
        e.stopPropagation(); // Prevent event bubbling

        const emoji = e.target.dataset.emoji;
        if (emoji && messageInput) {
          const currentValue = messageInput.value;
          const cursorPos = messageInput.selectionStart || 0;
          const newValue =
            currentValue.slice(0, cursorPos) +
            emoji +
            currentValue.slice(cursorPos);

          messageInput.value = newValue;
          messageInput.focus();

          // Set cursor position after the emoji
          const newCursorPos = cursorPos + emoji.length;
          setTimeout(() => {
            messageInput.setSelectionRange(newCursorPos, newCursorPos);
          }, 0);

          console.log("😊 Emoji added:", emoji);

          // DON'T close the picker immediately - let user select multiple emojis
          // emojiPicker.classList.remove('show');
        }
      }
    });

    // Close picker when user starts typing or presses Escape
    messageInput.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        emojiPicker.classList.remove("show");
        console.log("😊 Emoji picker closed - Escape pressed");
      }
    });

    messageInput.addEventListener("input", function () {
      // Only close if user is actively typing (not just from emoji insertion)
      if (document.activeElement === messageInput) {
        emojiPicker.classList.remove("show");
        console.log("😊 Emoji picker closed - user typing");
      }
    });
  }

  // Enhanced form submission
  if (messageForm) {
    messageForm.addEventListener("submit", function (e) {
      e.preventDefault();

      const content = messageInput.value.trim();
      if (!isValidMessage(content)) {
        showErrorMessage("Message not allowed");
        return;
      }

      // Close emoji picker when sending message
      if (emojiPicker) {
        emojiPicker.classList.remove("show");
        console.log("😊 Emoji picker closed - message sent");
      }

      const formData = new FormData(messageForm);
      const tempId = "temp_" + Date.now();

      // Add message to UI immediately
      const messageWrapper = document.createElement("div");
      messageWrapper.className = "d-flex justify-content-end mb-3";
      messageWrapper.dataset.messageId = tempId;
      messageWrapper.innerHTML = `
                <div class="chat-bubble user" data-new="true">
                    <div>${escapeHtml(content)}</div>
                    <span class="timestamp">${new Date().toLocaleTimeString(
                      "en-US",
                      { hour: "2-digit", minute: "2-digit", hour12: false }
                    )}</span>
                </div>
            `;

      if (messagesArea) {
        messagesArea.appendChild(messageWrapper);
        scrollToBottom(true);
        hasNewerMessages = false;
      }
      messageInput.value = "";
      updateScrollIndicators();

      console.log("📤 Message sent to UI, sending to server...");

      // Send to server
      fetch("", {
        method: "POST",
        body: formData,
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRFToken": getCSRFToken(),
        },
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
          }
          return response.json();
        })
        .then((data) => {
          console.log("✅ Server response:", data);
          if (!data.success) {
            messageWrapper.remove();
            messageInput.value = content;
            showErrorMessage(data.error || "Failed to send message. Try again!");
          } else {
            // Update with real message ID if provided
            if (data.message_id) {
              messageWrapper.dataset.messageId = data.message_id;
              newestMessageId = data.message_id;
              console.log("🆔 Message ID updated:", data.message_id);
            }
          }
        })
        .catch((error) => {
          messageWrapper.remove();
          messageInput.value = content;
          console.error("💥 Error:", error);
          showErrorMessage("Connection error. Please check your internet!");
        });
    });
  }

  // Utility functions
  function showErrorMessage(message) {
    const errorDiv = document.createElement("div");
    errorDiv.className =
      "alert alert-danger alert-dismissible fade show position-fixed";
    errorDiv.style.cssText =
      "top: 90px; right: 20px; z-index: 9999; max-width: 300px;";
    errorDiv.innerHTML = `
            ${escapeHtml(message)}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
    document.body.appendChild(errorDiv);

    setTimeout(() => {
      if (errorDiv.parentNode) {
        errorDiv.remove();
      }
    }, 5000);
  }

  function escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  // Auto-focus input
  setTimeout(() => {
    if (messageInput) {
      messageInput.focus();
      console.log("🎯 Input focused");
    }
  }, 1000);

  // Enter key support
  if (messageInput) {
    messageInput.addEventListener("keypress", function (e) {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        if (messageForm) {
          messageForm.dispatchEvent(new Event("submit"));
        }
      }
    });
  }

  // Keyboard navigation migliorata
  document.addEventListener("keydown", function (e) {
    if (
      e.target === messageInput ||
      (emojiPicker && emojiPicker.classList.contains("show"))
    )
      return; // Don't interfere with typing or emoji selection

    if (e.key === "PageUp" || (e.key === "ArrowUp" && e.ctrlKey)) {
      e.preventDefault();
      if (hasMoreMessages && !isLoadingMessages) {
        loadOlderMessages();
      } else {
        messagesArea.scrollBy({ top: -200, behavior: "smooth" });
      }
    }

    if (e.key === "PageDown" || (e.key === "ArrowDown" && e.ctrlKey)) {
      e.preventDefault();
      if (hasNewerMessages && !isLoadingMessages) {
        loadNewerMessages();
      } else {
        messagesArea.scrollBy({ top: 200, behavior: "smooth" });
      }
    }

    if (e.key === "Home" && e.ctrlKey) {
      e.preventDefault();
      scrollToTop();
    }

    if (e.key === "End" && e.ctrlKey) {
      e.preventDefault();
      scrollToBottom(true);
    }
  });

  // Periodic check for new messages con intervallo ottimizzato
  setInterval(() => {
    if (!isLoadingMessages && !isUserScrolling) {
      loadNewerMessages();
    }
  }, 3000); // Ridotto a 3 secondi per migliore responsività

  // Re-apply fixes periodically to ensure stability
  setInterval(() => {
    ensureInputAreaVisible();
    ensureMessagesAreaHeight();
  }, 5000);

  // Initialize indicators
  updateScrollIndicators();

  console.log(
    "✅ Chat initialized successfully with enhanced scrolling and persistent input bar"
  );
});
