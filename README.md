# Oh! My Sushi Telegram Bot

Telegram бот для заказа суши из ресторана Oh! My Sushi.

## Установка

1. Установите Ruby (если еще не установлен)
2. Установите зависимости:
```bash
bundle install
```

3. Создайте файл `.env` и добавьте в него:
```
TELEGRAM_BOT_TOKEN=your_bot_token_here
ADMIN_CHAT_ID=your_admin_chat_id_here
```

## Запуск

1. Запустите бота:
```bash
ruby lib/bot.rb
```

## Функционал

- Просмотр меню по категориям
- Добавление товаров в корзину
- Оформление заказов
- Уведомления администратору о новых заказах

## Структура проекта

- `lib/bot.rb` - основной файл бота
- `lib/models.rb` - модели данных
- `lib/scraper.rb` - парсер меню с сайта
- `db/sushi_bot.sqlite3` - база данных 