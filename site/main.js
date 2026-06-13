const apiConfig = window.API_CONFIG || {};
const isApiConfigured =
  apiConfig.subscribeUrl &&
  !apiConfig.subscribeUrl.includes('YOUR_WORKER_URL');

function setFormStatus(form, message, type) {
  const status = form.parentElement?.querySelector('.form-status');
  if (!status) return;

  status.textContent = message;
  status.dataset.type = type;
}

function normalizeEmail(value) {
  return value.trim().toLowerCase();
}

async function saveSubscriber(form, email) {
  const response = await fetch(apiConfig.subscribeUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email,
      language: form.dataset.language || document.documentElement.lang || 'ru',
      source: form.dataset.source || 'landing',
      page: window.location.href,
      user_agent: navigator.userAgent,
    }),
  });

  const payload = await response.json().catch(() => ({}));

  if (!response.ok) {
    throw new Error(payload.error || `API responded with ${response.status}`);
  }
}

document.querySelectorAll('.notify-form').forEach((form) => {
  form.addEventListener('submit', async (event) => {
    event.preventDefault();

    const emailInput = form.querySelector('[name="email"]');
    const honeypot = form.querySelector('[name="website"]');
    const button = form.querySelector('button[type="submit"]');
    const email = normalizeEmail(emailInput?.value || '');

    if (honeypot?.value) {
      setFormStatus(form, '', 'success');
      form.reset();
      return;
    }

    if (!emailInput?.checkValidity()) {
      emailInput?.reportValidity();
      return;
    }

    if (!isApiConfigured) {
      setFormStatus(form, form.dataset.configError || 'Form is not connected to the API yet.', 'error');
      return;
    }

    button.disabled = true;
    setFormStatus(form, form.dataset.pending || 'Saving email...', 'pending');

    try {
      await saveSubscriber(form, email);
      form.reset();
      setFormStatus(form, form.dataset.success || 'Email saved.', 'success');
    } catch (error) {
      console.error(error);
      setFormStatus(form, form.dataset.error || 'Could not save email. Please try again.', 'error');
    } finally {
      button.disabled = false;
    }
  });
});
