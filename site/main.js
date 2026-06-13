// Простая обработка формы без Formspree (fallback — mailto)
document.querySelectorAll('.notify-form').forEach((form) => {
  form.addEventListener('submit', (e) => {
    const action = form.getAttribute('action') || '';
    if (action.includes('YOUR_FORM_ID')) {
      e.preventDefault();
      const email = form.querySelector('[name="email"]')?.value;
      if (email) {
        window.location.href = `mailto:hello@YOUR_DOMAIN?subject=Подписка: Автономный Агент&body=Email: ${encodeURIComponent(email)}`;
      }
    }
  });
});
