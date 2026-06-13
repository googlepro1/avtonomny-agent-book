const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return withCors(new Response(null, { status: 204 }), request, env);
    }

    if (url.pathname === '/api/health') {
      return withCors(jsonResponse({ ok: true }), request, env);
    }

    if (url.pathname === '/api/subscribe' && request.method === 'POST') {
      return withCors(await handleSubscribe(request, env), request, env);
    }

    return withCors(jsonResponse({ error: 'Not found' }, 404), request, env);
  },
};

async function handleSubscribe(request, env) {
  if (!env.DB) {
    return jsonResponse({ error: 'Database is not configured' }, 503);
  }

  let payload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  if (payload.website) {
    return jsonResponse({ ok: true });
  }

  const email = String(payload.email || '').trim().toLowerCase();
  if (!EMAIL_PATTERN.test(email)) {
    return jsonResponse({ error: 'Invalid email' }, 400);
  }

  const language = String(payload.language || 'ru').slice(0, 8);
  const source = String(payload.source || 'landing').slice(0, 120);
  const page = String(payload.page || '').slice(0, 500);
  const userAgent = String(payload.user_agent || request.headers.get('User-Agent') || '').slice(0, 500);
  const ip = request.headers.get('CF-Connecting-IP') || '';

  try {
    await env.DB.prepare(
      `INSERT INTO subscribers (email, language, source, page, user_agent, ip)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6)`
    ).bind(email, language, source, page, userAgent, ip).run();
  } catch (error) {
    if (String(error?.message || '').includes('UNIQUE constraint failed')) {
      return jsonResponse({ ok: true, duplicate: true });
    }
    console.error(error);
    return jsonResponse({ error: 'Failed to save email' }, 500);
  }

  return jsonResponse({ ok: true });
}

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function withCors(response, request, env) {
  const origin = request.headers.get('Origin') || '';
  const allowedOrigins = String(env.ALLOWED_ORIGINS || '')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean);

  const headers = new Headers(response.headers);
  headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Content-Type');
  headers.set('Vary', 'Origin');

  if (allowedOrigins.includes('*')) {
    headers.set('Access-Control-Allow-Origin', origin || '*');
  } else if (origin && allowedOrigins.includes(origin)) {
    headers.set('Access-Control-Allow-Origin', origin);
  }

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
