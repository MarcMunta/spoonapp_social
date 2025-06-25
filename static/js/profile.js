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

const storyInput = document.getElementById("id_media_file");
if (storyInput) {
  storyInput.addEventListener("change", () => {
    document.getElementById("storyForm")?.submit();
  });
  const addBtn = document.querySelector(".profile-story-add");
  if (addBtn) {
    addBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      storyInput.click();
    });
  }
}

document.addEventListener("DOMContentLoaded", function () {
  const tabs = document.querySelectorAll("#categoryTabs .nav-link");
  const groups = document.querySelectorAll(".category-group");

  tabs.forEach((tab) => {
    tab.addEventListener("click", (e) => {
      e.preventDefault();
      const selected = tab.dataset.category;

      // Cambiar pestaña activa
      tabs.forEach((t) => t.classList.remove("active"));
      tab.classList.add("active");

      // Mostrar la categoría correspondiente
      groups.forEach((group) => {
        if (group.dataset.category === selected) {
          group.style.display = "flex";
        } else {
          group.style.display = "none";
        }
      });
    });
  });
});
