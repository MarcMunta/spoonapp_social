document.addEventListener('DOMContentLoaded', () => {
  const dropZone = document.getElementById('dropZone');
  if (dropZone) {
    const input = dropZone.querySelector('input[type="file"]');
    dropZone.addEventListener('click', () => input.click());
    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault();
      dropZone.classList.add('drag-over');
    });
    dropZone.addEventListener('dragleave', () => dropZone.classList.remove('drag-over'));
    dropZone.addEventListener('drop', (e) => {
      e.preventDefault();
      dropZone.classList.remove('drag-over');
      if (e.dataTransfer.files.length) {
        input.files = e.dataTransfer.files;
      }
    });
  }

});
