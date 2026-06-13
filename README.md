# Книга «Автономный Агент»

Лендинг и материалы книги. Сайт публикуется через **GitHub Pages** (папка `site/`).

## Опубликовать на GitHub Pages

```bash
# 1. Один раз — войти в GitHub
gh auth login

# 2. Создать репо и запушить (имя по умолчанию: avtonomny-agent-book)
./scripts/publish-github-pages.sh
```

Через 1–2 минуты сайт будет по адресу:

`https://ВАШ_ЛОГИН.github.io/avtonomny-agent-book/`

В репозитории: **Settings → Pages → Build and deployment → Source: GitHub Actions**.

## Свой домен

1. Создайте `site/CNAME` с одной строкой — ваш домен.
2. В DNS: CNAME на `ВАШ_ЛОГИН.github.io` или A-записи GitHub Pages.
3. Закоммитьте и запушьте.

## Локально

```bash
cd site && python3 -m http.server 8080
```
