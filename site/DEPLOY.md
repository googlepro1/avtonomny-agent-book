# Публикация лендинга и сбора email

## Текущая схема (prod)

```text
https://googlepro1.github.io/avtonomny-agent-book/
        |
        | POST /api/subscribe
        v
https://avtonomny-agent-subscribers.mikxyotubes.workers.dev
        |
        v
Cloudflare D1: subscribers
```

Форма на лендинге уже подключена через `site/api-config.js`.

## GitHub Pages

1. Push в ветку `main`.
2. Workflow `.github/workflows/deploy-pages.yml` публикует папку `site/`.
3. Сайт: https://googlepro1.github.io/avtonomny-agent-book/

### Свой домен

| Файл | Действие |
|------|----------|
| `site/CNAME` | одна строка — ваш домен |
| DNS | CNAME на `googlepro1.github.io` или A-записи GitHub Pages |
| `wrangler.toml` | добавить домен в `ALLOWED_ORIGINS` |

A-записи GitHub Pages: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`

## Форма подписки

### Как это работает

1. Пользователь вводит email на `index.html` или `en.html`.
2. `site/main.js` отправляет JSON на Worker.
3. Worker пишет строку в таблицу `subscribers` (D1).
4. Повторная подписка с тем же email не создаёт дубликат.

### Конфиг сайта

`site/api-config.js`:

```js
window.API_CONFIG = {
  subscribeUrl: 'https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/subscribe',
};
```

### Пересоздать API

```bash
cd ..   # корень репозитория
npm install
npx wrangler login
npx wrangler d1 migrations apply subscribers --remote
npx wrangler deploy
```

### Экспорт email

```bash
npx wrangler d1 execute subscribers --remote --command \
  "SELECT * FROM subscribers ORDER BY created_at DESC"
```

CSV вручную: Cloudflare Dashboard → D1 → subscribers → Export.

## Локальный просмотр

```bash
cd site
python3 -m http.server 8080
```

Откройте http://localhost:8080

Для теста формы локально запустите Worker:

```bash
npx wrangler dev
```

и временно укажите `http://127.0.0.1:8787/api/subscribe` в `api-config.js`.

## CI (GitHub Actions)

Workflow `.github/workflows/deploy-subscriber-api.yml` деплоит Worker и применяет миграции D1 при изменениях в `worker/`, `migrations/` или `wrangler.toml`.

Секреты репозитория:

```bash
CLOUDFLARE_API_TOKEN='your-token' ./scripts/setup-github-secrets.sh
```

Проверка вручную:

```bash
gh workflow run deploy-subscriber-api.yml --repo googlepro1/avtonomny-agent-book
```

## Безопасность

- CORS: только origins из `ALLOWED_ORIGINS` в `wrangler.toml`
- Honeypot-поле `website` в форме
- Уникальный индекс на `email`
- Публичный доступ только на **создание** записи; чтение — через Wrangler/Dashboard

Опционально: Cloudflare Turnstile на форме.

## PocketBase (только для локальных экспериментов)

Папка `pocketbase/` — альтернатива для отладки на своей машине.
**Не используйте для GitHub Pages.** См. `pocketbase/README.md`.
