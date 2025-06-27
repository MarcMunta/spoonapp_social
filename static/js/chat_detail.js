function initChatDetail() {
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
  const userBubbleColor = document.body.dataset.bubbleColor || "#db6ec4";

  const blockedWords = ["cola", "gay", "puta"];
  function isValidMessage(msg) {
    if (!msg || msg.trim().length < 3) return false;
    const text = msg.toLowerCase();
    return !blockedWords.some((w) => text.includes(w));
  }


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
    }
  }

  function scrollToTop() {
    if (messagesArea) {
      messagesArea.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    }
  }

  // Scroll to bottom on initial load
  setTimeout(() => {
    scrollToBottom(true);
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
            loadOlderMessages();
          }

          if (
            scrollTop + clientHeight >= scrollHeight - 150 &&
            delta > 0 &&
            hasNewerMessages &&
            !isLoadingMessages
          ) {
            loadNewerMessages();
          }
        }, 100);

        scrollTimer = setTimeout(() => {
          isUserScrolling = false;
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

          scrollTop,
          scrollHeight,
          clientHeight,
        });

        // Auto-load older messages when scrolled to top
        if (scrollTop <= 100 && hasMoreMessages && !isLoadingMessages) {
          loadOlderMessages();
        }

        // Auto-load newer messages when scrolled to bottom
        if (
          scrollTop + clientHeight >= scrollHeight - 100 &&
          hasNewerMessages &&
          !isLoadingMessages
        ) {
          loadNewerMessages();
        }

        updateScrollIndicators();
      }, 150);
    });
  }

  // Click handlers for scroll indicators
  if (scrollTopIndicator) {
    scrollTopIndicator.addEventListener("click", function () {
      if (hasMoreMessages) {
        loadOlderMessages();
      } else {
        scrollToTop();
      }
    });
  }

  if (scrollBottomIndicator) {
    scrollBottomIndicator.addEventListener("click", function () {
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
        isLoadingMessages,
        hasMoreMessages,
        oldestMessageId,
      });
      return;
    }

    isLoadingMessages = true;
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

    fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
      })
      .then((data) => {

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
                        } spoon-message-loaded" style="--bubble-color:${msg.bubble_color}">
                            <div>${escapeHtml(msg.content)}</div>
                            <span class="timestamp">${msg.sent_at}</span>
                        </div>
                    `;
            messagesArea.insertBefore(messageWrapper, messagesArea.firstChild);
          });

          // Update oldest message ID
          oldestMessageId = data.messages[0].id;
          hasMoreMessages = data.has_more;
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
        }

        isLoadingMessages = false;
        updateScrollIndicators();
      })
      .catch((error) => {
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
        isLoadingMessages,
        newestMessageId,
      });
      return;
    }

    isLoadingMessages = true;
    updateScrollIndicators();

    const url = `/chat/${chatId}/messages/?after=${newestMessageId}&limit=20`;

    fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.json();
      })
      .then((data) => {

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
                        }" data-new="true" style="--bubble-color:${msg.bubble_color}">
                            <div>${escapeHtml(msg.content)}</div>
                            <span class="timestamp">${msg.sent_at}</span>
                        </div>
                    `;
            messagesArea.appendChild(messageWrapper);
          });

          // Update newest message ID
          newestMessageId = data.messages[data.messages.length - 1].id;
          hasNewerMessages = data.has_more || false;
            "✅ Updated newestMessageId:",
            newestMessageId,
            "hasNewerMessages:",
            hasNewerMessages
          );
        } else {
          hasNewerMessages = false;
        }

        isLoadingMessages = false;
        updateScrollIndicators();
      })
      .catch((error) => {
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
    } else if (!isScrolledUp && scrollFloatingBtn) {
      scrollFloatingBtn.remove();
      scrollFloatingBtn = null;
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
    });

    // Close picker when clicking outside
    document.addEventListener("click", function (e) {
      if (
        emojiPicker &&
        !emojiBtn.contains(e.target) &&
        !emojiPicker.contains(e.target)
      ) {
        emojiPicker.classList.remove("show");
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


          // DON'T close the picker immediately - let user select multiple emojis
          // emojiPicker.classList.remove('show');
        }
      }
    });

    // Close picker when user starts typing or presses Escape
    messageInput.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        emojiPicker.classList.remove("show");
      }
    });

    messageInput.addEventListener("input", function () {
      // Only close if user is actively typing (not just from emoji insertion)
      if (document.activeElement === messageInput) {
        emojiPicker.classList.remove("show");
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
      }

      const formData = new FormData(messageForm);
      const tempId = "temp_" + Date.now();

      // Add message to UI immediately
      const messageWrapper = document.createElement("div");
      messageWrapper.className = "d-flex justify-content-end mb-3";
      messageWrapper.dataset.messageId = tempId;
      messageWrapper.innerHTML = `
                <div class="chat-bubble user" data-new="true" style="--bubble-color:${userBubbleColor}">
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
          if (!data.success) {
            messageWrapper.remove();
            messageInput.value = content;
            showErrorMessage(data.error || "Failed to send message. Try again!");
          } else {
            // Update with real message ID if provided
            if (data.message_id) {
              messageWrapper.dataset.messageId = data.message_id;
              newestMessageId = data.message_id;
            }
          }
        })
        .catch((error) => {
          messageWrapper.remove();
          messageInput.value = content;
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

    "✅ Chat initialized successfully with enhanced scrolling and persistent input bar"
  );
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initChatDetail);
} else {
  initChatDetail();
}
