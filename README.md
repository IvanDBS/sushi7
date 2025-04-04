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

## База данных

Проект использует PostgreSQL для хранения данных. База данных создается автоматически при первом запуске скрапера.

### Структура базы данных

- `categories` - категории товаров
- `products` - товары
- `product_categories` - связи между товарами и категориями
- `users` - пользователи бота
- `orders` - заказы
- `order_items` - позиции в заказе

### Локальная разработка

Для локальной разработки используется PostgreSQL. База данных создается автоматически при первом запуске скрапера.

## Структура проекта

```
sushi7/
├── lib/
│   ├── bot.rb           # Основной файл бота
│   ├── scraper.rb       # Скрапер для парсинга меню
│   ├── models.rb        # Модели базы данных
│   ├── ingredients.rb   # Обработка ингредиентов
│   └── admin_commands.rb # Административные команды
├── db/
│   ├── migrations/      # Миграции базы данных
│   ├── schema.sql      # Схема базы данных
│   └── data.sql        # Начальные данные
├── config/
│   └── database.yml    # Конфигурация базы данных
├── Gemfile             # Зависимости проекта
├── docker-compose.dev.yml # Конфигурация Docker для разработки
└── README.md           # Документация проекта
``` 