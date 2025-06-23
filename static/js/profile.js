const bubble = document.getElementById("profileColorBubble");
const dropdown = document.getElementById("colorDropdown");
bubble?.addEventListener("click", () => {
  dropdown?.classList.toggle("d-none");
});
dropdown?.querySelectorAll(".color-option").forEach((opt) => {
  opt.addEventListener("click", () => {
    const color = opt.dataset.color;
    const url = bubble.dataset.updateUrl;
    fetch(url, {
      method: "POST",
      headers: { "X-CSRFToken": getCSRFToken() },
      body: new URLSearchParams({ color }),
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.success) {
          bubble.style.backgroundColor = data.color;
          dropdown.classList.add("d-none");
        }
      });
  });
});
