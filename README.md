# Книга «Автономный Агент»

Лендинг книги, отрывки и материалы. Сайт на **GitHub Pages**, подписки на email — в **вашей базе Cloudflare D1**.

## Живые адреса

| Что | URL |
|-----|-----|
| Лендинг (RU) | https://googlepro1.github.io/avtonomny-agent-book/ |
| Лендинг (EN) | https://googlepro1.github.io/avtonomny-agent-book/en.html |
| API подписчиков | https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/subscribe |
| Репозиторий | https://github.com/googlepro1/avtonomny-agent-book |

## Архитектура

GitHub Pages не умеет хранить данные. Поэтому используется разделение:

```text
GitHub Pages (site/)  --POST-->  Cloudflare Worker  -->  Cloudflare D1
   статика                         /api/subscribe          subscribers
```

- **GitHub Pages** — лендинг, отрывки, стили
- **Cloudflare Worker** — принимает email с формы
- **Cloudflare D1** — ваша SQLite-база; экспорт через Wrangler или Dashboard

Подробности: [`worker/README.md`](worker/README.md)

## Быстрый старт

### Лендинг (уже настроен)

Сайт деплоится через GitHub Actions при push в `main`:

```bash
git push origin main
```

Workflow: `.github/workflows/deploy-pages.yml`

### Форма подписки (уже настроена)

Конфиг формы: `site/api-config.js`

```js
window.API_CONFIG = {
  subscribeUrl: 'https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/subscribe',
};
```

Проверка API:

```bash
curl -s https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/health
# {"ok":true}
```

### Посмотреть собранные email

```bash
npm install
npx wrangler d1 execute subscribers --remote --command \
  "SELECT email, language, source, created_at FROM subscribers ORDER BY created_at DESC"
```

Или: Cloudflare Dashboard → **D1** → **subscribers** → Query.

## Пересборка с нуля

### 1. GitHub Pages

```bash
gh auth login
./scripts/publish-github-pages.sh
```

### 2. API + база

```bash
npm install
npx wrangler login
npx wrangler d1 create subscribers   # один раз; id → wrangler.toml
npx wrangler d1 migrations apply subscribers --remote
npx wrangler deploy
```

URL Worker после деплоя вставьте в `site/api-config.js`.

Полный чеклист: `./scripts/setup-cloudflare.sh`

### CI для Worker (GitHub Actions)

Workflow: `.github/workflows/deploy-subscriber-api.yml`

Секреты репозитория (уже настроены):

| Secret | Значение |
|--------|----------|
| `CLOUDFLARE_ACCOUNT_ID` | `f8750e2eca8b02dc184b196bd36a155d` |
| `CLOUDFLARE_API_TOKEN` | токен Cloudflare (см. ниже) |

Пересоздать секреты:

```bash
CLOUDFLARE_API_TOKEN='your-token' ./scripts/setup-github-secrets.sh
```

Рекомендуется **долгоживущий** API Token (шаблон «Edit Cloudflare Workers») в [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens). OAuth-токен от `wrangler login` тоже работает, но истекает через несколько дней.

## Локальная разработка

```bash
# Лендинг
cd site && python3 -m http.server 8080

# API (в другом терминале)
npx wrangler d1 migrations apply subscribers --local
npx wrangler dev
```

Для локального теста формы временно укажите в `site/api-config.js`:

```js
subscribeUrl: 'http://127.0.0.1:8787/api/subscribe',
```

## Свой домен

1. Создайте `site/CNAME` с доменом (см. `site/CNAME.example`).
2. Настройте DNS у регистратора.
3. Добавьте домен в `ALLOWED_ORIGINS` в `wrangler.toml` и выполните `npx wrangler deploy`.

## Структура проекта

```text
site/                 # лендинг (GitHub Pages)
worker/src/index.js   # Cloudflare Worker
migrations/           # SQL-схема D1
wrangler.toml         # конфиг Worker + D1
pocketbase/           # опционально: локальные эксперименты (не для prod)
```

## Автодеплой API через GitHub Actions

Workflow: `.github/workflows/deploy-subscriber-api.yml`

Secrets в репозитории (Settings → Secrets):

- `CLOUDFLARE_API_TOKEN` — токен с правами Workers + D1
- `CLOUDFLARE_ACCOUNT_ID` — `f8750e2eca8b02dc184b196bd36a155d`

Создание токена: Cloudflare Dashboard → My Profile → API Tokens → Create Token → Edit Cloudflare Workers.
