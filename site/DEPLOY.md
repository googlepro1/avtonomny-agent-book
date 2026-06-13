# Публикация лендинга книги (бесплатно + свой домен)

Папка `site/` — статический лендинг. Хостинг **0 ₽**.

## Быстрый старт: GitHub Pages

1. Создайте репозиторий на GitHub (например `avtonomny-agent-book`).
2. Залейте содержимое **папки `site/`** в корень репо (или весь проект — см. ниже).
3. **Settings → Pages → Source:** Deploy from branch `main`, folder `/site` или `/ (root)`.
4. В `site/CNAME` замените `YOUR_DOMAIN` на ваш домен, например `kniga.example.com`.
5. У регистратора домена добавьте DNS:
   - **A-записи** на GitHub Pages: `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`
   - или **CNAME** `kniga` → `username.github.io`
6. В GitHub Pages включите **Enforce HTTPS**.

Сайт: `https://YOUR_DOMAIN`

## Альтернатива: Cloudflare Pages (тоже бесплатно)

1. [dash.cloudflare.com](https://dash.cloudflare.com) → Pages → Create project.
2. Подключите GitHub-репо или загрузите папку `site/` вручную (Direct Upload).
3. Build command: *(пусто)* · Output directory: `site` (или `.` если залили только site).
4. Custom domains → добавьте домен (если DNS уже на Cloudflare — один клик).

## Что заменить перед публикацией

| Файл | Заменить |
|------|----------|
| `site/CNAME` | ваш домен |
| `site/index.html` | `YOUR_DOMAIN` в mailto и Formspree |
| `site/index.html` | `YOUR_FORM_ID` в Formspree (бесплатно: [formspree.io](https://formspree.io)) |

### Formspree (форма подписки)

1. Зарегистрируйтесь на formspree.io.
2. Создайте форму → скопируйте id вида `xyzabcde`.
3. В `index.html` замените `https://formspree.io/f/YOUR_FORM_ID` на ваш URL.

Без Formspree форма откроет mailto (см. `main.js`).

## Локальный просмотр

```bash
cd site
python3 -m http.server 8080
```

Откройте http://localhost:8080

## Промо-линия (Fable 5)

На лендинге зафиксировано:

- книга написана **Fable 5** в период полного доступа;
- после отключения/ограничений текст остался уникальным артеfactом;
- это ключевой маркетинговый угол для соцсетей и анонсов.

При необходимости уточните формулировки в `index.html` (секция `#story` и footer).
