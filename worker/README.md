# API подписчиков (Cloudflare Worker + D1)

Backend для формы «Уведомить о выходе» на лендинге книги.

## Prod

| Компонент | Значение |
|-----------|----------|
| Worker | `avtonomny-agent-subscribers` |
| URL | https://avtonomny-agent-subscribers.mikxyotubes.workers.dev |
| Endpoint | `POST /api/subscribe` |
| Health | `GET /api/health` → `{"ok":true}` |
| D1 database | `subscribers` |
| D1 id | `e562b04c-5647-4170-ab16-32224b05c852` |

## Зачем так

GitHub Pages отдаёт только статику. Email нужно хранить отдельно.

```text
GitHub Pages  →  Worker (edge API)  →  D1 (ваша SQLite)
```

Плюсы:

- своя база, экспорт в любой момент
- бесплатный tier Cloudflare
- не нужен VPS и Docker
- работает с GitHub Pages из коробки

## Файлы

| Файл | Назначение |
|------|------------|
| `worker/src/index.js` | обработчик `/api/subscribe` |
| `migrations/0001_subscribers.sql` | схема таблицы |
| `wrangler.toml` | binding D1, CORS origins |
| `site/api-config.js` | URL API для лендинга |
| `site/main.js` | отправка формы |

## Схема таблицы

```sql
subscribers (
  id, email UNIQUE, language, source, page, user_agent, ip, created_at
)
```

## Команды

```bash
# Установка
npm install
npx wrangler login

# Миграция (prod)
npx wrangler d1 migrations apply subscribers --remote

# Деплой
npx wrangler deploy

# Список подписчиков
npx wrangler d1 execute subscribers --remote --command \
  "SELECT email, language, source, created_at FROM subscribers ORDER BY created_at DESC"

# Локальная разработка
npx wrangler d1 migrations apply subscribers --local
npx wrangler dev
```

## CORS

В `wrangler.toml`:

```toml
[vars]
ALLOWED_ORIGINS = "https://googlepro1.github.io,http://127.0.0.1:8080,http://localhost:8080"
```

При добавлении своего домена — допишите origin и выполните `npx wrangler deploy`.

## GitHub Actions

Workflow: `.github/workflows/deploy-subscriber-api.yml`

Secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID` = `f8750e2eca8b02dc184b196bd36a155d`

Деплой Worker срабатывает при изменениях в `worker/`, `migrations/`, `wrangler.toml`.

## Тест вручную

```bash
curl -s https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/health

curl -s -X POST https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/subscribe \
  -H "Content-Type: application/json" \
  -H "Origin: https://googlepro1.github.io" \
  -d '{"email":"you@example.com","language":"ru","source":"manual-test"}'
```

## Безопасность

- валидация email на Worker
- honeypot в форме
- unique constraint на email
- CORS по whitelist
- IP сохраняется из `CF-Connecting-IP`

Следующий шаг при росте трафика: Cloudflare Turnstile.
