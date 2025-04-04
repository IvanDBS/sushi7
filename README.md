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

## Admin Commands

The bot includes several administrative commands for managing products:

- `/list_products` - Show a list of all products with their IDs and prices
- `/find_product [name]` - Find a product by name
- `/product_info [id]` - Show detailed information about a product
- `/edit_price [id] [new_price]` - Change the regular price of a product
- `/set_sale [id] [sale_price]` - Set a sale price for a product
- `/remove_sale [id]` - Remove a product from sale
- `/sale_products` - Show a list of all products on sale

## Структура проекта

- `lib/bot.rb` - основной файл бота
- `lib/models.rb` - модели данных
- `lib/scraper.rb` - парсер меню с сайта
- `db/sushi_bot.sqlite3` - база данных 