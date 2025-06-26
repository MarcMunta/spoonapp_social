
document.addEventListener('DOMContentLoaded', () => {
  const input = document.getElementById('id_location');
  if (!input) return;
  input.setAttribute('autocomplete', 'off');
  const list = document.createElement('ul');
  list.className = 'autocomplete-list';
  input.parentNode.appendChild(list);

  let timeoutId;

  input.addEventListener('input', () => {
    const q = input.value.trim();
    if (q.length < 2) {
      list.style.display = 'none';
      list.innerHTML = '';
      return;
    }

    list.style.display = 'block';
    list.innerHTML = '<li>Loading...</li>';

    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      fetch(`${LANG_PREFIX}/api/location-search/?q=${encodeURIComponent(q)}`)
        .then(res => res.json())
        .then(data => {
          list.innerHTML = '';
          data.forEach(loc => {
            const li = document.createElement('li');
            li.textContent = loc.display_name;
            li.addEventListener('click', () => {
              let val = loc.display_name;
              const max = input.getAttribute('maxlength');
              if (max && val.length > parseInt(max)) {
                val = val.slice(0, max);
              }
              input.value = val;
              list.innerHTML = '';
              list.style.display = 'none';
            });
            list.appendChild(li);
          });
          list.style.display = data.length ? 'block' : 'none';
        })
        .catch(() => {
          list.style.display = 'none';
        });
    }, 300);
  });

  document.addEventListener('click', (e) => {
    if (e.target !== input && !list.contains(e.target)) {
      list.style.display = 'none';
    }
  });
});
