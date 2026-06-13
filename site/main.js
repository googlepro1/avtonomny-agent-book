// Простая обработка формы без Formspree (fallback — mailto)
document.querySelectorAll('.notify-form').forEach((form) => {
  form.addEventListener('submit', (e) => {
    const action = form.getAttribute('action') || '';
    if (action.includes('YOUR_FORM_ID')) {
      e.preventDefault();
      const email = form.querySelector('[name="email"]')?.value;
      const subject = form.dataset.mailtoSubject || 'Подписка: Автономный Агент';
      if (email) {
        window.location.href = `mailto:hello@YOUR_DOMAIN?subject=${encodeURIComponent(subject)}&body=Email: ${encodeURIComponent(email)}`;
      }
    }
  });
});
