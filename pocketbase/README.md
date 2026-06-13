# PocketBase (опционально, только локально)

> **Не используется в production.**  
> Для публичного лендинга на GitHub Pages работает **Cloudflare Worker + D1**.  
> См. [`worker/README.md`](../worker/README.md).

PocketBase — локальная альтернатива для экспериментов на своей машине: один бинарник, SQLite, админка.

## Запуск

```bash
./scripts/install-pocketbase.sh
./scripts/run-pocketbase.sh
```

- API: http://127.0.0.1:8090
- Админка: http://127.0.0.1:8090/_/

При первом входе создайте admin-аккаунт. Коллекция `subscribers` создаётся из `pocketbase/pb_migrations/`.

## Почему не для prod

Лендинг на GitHub Pages не может обращаться к `127.0.0.1` на вашем компьютере.
Для публичного сбора email нужен Worker + D1 или VPS с HTTPS.
