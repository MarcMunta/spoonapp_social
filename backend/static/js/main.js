function e() {
  let n = document.getElementById("app");
  n && (n.innerHTML = "<p>Frontend bundle loaded via ESM!</p>");
}
typeof window < "u" && window.addEventListener("DOMContentLoaded", e);
export { e as initialize };
