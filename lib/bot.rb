require 'telegram/bot'
require 'dotenv/load'
require_relative 'models'
require_relative 'scraper'

class SushiBot
  def initialize
    @token = ENV['TELEGRAM_BOT_TOKEN']
    @admin_chat_id = ENV['ADMIN_CHAT_ID']
  end

  def update_menu
    puts "\n=== Обновление меню из сайта ==="
    MenuScraper.scrape_menu
    puts "=== Меню обновлено! ===\n"
  end

  def start
    Telegram::Bot::Client.run(@token) do |bot|
      puts 'Бот запущен'
      
      bot.listen do |message|
        begin
          case message
          when Telegram::Bot::Types::Message
            if message.from.id.to_s == @admin_chat_id && message.text == '/update_menu'
              update_menu
              bot.api.send_message(
                chat_id: message.chat.id,
                text: "Меню успешно обновлено!"
              )
              next
            end

            user = User.find_or_create_by(telegram_id: message.from.id) do |u|
              u.first_name = message.from.first_name
              u.last_name = message.from.last_name
            end
            handle_message(bot, message, user)
            
          when Telegram::Bot::Types::CallbackQuery
            user = User.find_or_create_by(telegram_id: message.from.id) do |u|
              u.first_name = message.from.first_name
              u.last_name = message.from.last_name
            end
            handle_callback(bot, message, user)
          end
        rescue => e
          puts "Ошибка: #{e.message}"
          puts e.backtrace
          chat_id = message.is_a?(Telegram::Bot::Types::CallbackQuery) ? message.message.chat.id : message.chat.id
          bot.api.send_message(
            chat_id: chat_id,
            text: "Произошла ошибка. Пожалуйста, попробуйте позже."
          )
        end
      end
    end
  end

  private

  def handle_message(bot, message, user)
    case message.text
    when '/start'
      send_welcome_message(bot, message)
    when '🍱 Меню'
      show_categories(bot, message)
    when '🛒 Корзина'
      show_cart(bot, message, user)
    when '📞 Контакты'
      show_contacts(bot, message)
    else
      handle_text_input(bot, message, user)
    end
  end

  def send_welcome_message(bot, message)
    keyboard = [
      [{ text: '🍱 Меню' }],
      [{ text: '🛒 Корзина' }],
      [{ text: '📞 Контакты' }]
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: keyboard,
      resize_keyboard: true
    )
    
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "Добро пожаловать в Oh! My Sushi! 🍣\nВыберите действие:",
      reply_markup: markup
    )
  end

  def show_categories(bot, message_or_callback)
    categories = Category.all
    buttons = categories.each_slice(2).map do |category_pair|
      category_pair.map do |category|
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: category.name,
          callback_data: "category_#{category.id}"
        )
      end
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    # Определяем chat_id в зависимости от типа входящего объекта
    chat_id = if message_or_callback.is_a?(Telegram::Bot::Types::CallbackQuery)
                message_or_callback.message.chat.id
              else
                message_or_callback.chat.id
              end

    bot.api.send_message(
      chat_id: chat_id,
      text: 'Выберите категорию:',
      reply_markup: markup
    )
  end

  def handle_callback(bot, callback_query, user)
    case callback_query.data
    when /^category_(\d+)$/
      show_category_products(bot, callback_query, $1)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when /^product_(\d+)$/
      show_product_details(bot, callback_query, $1)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when /^add_to_cart_(\d+)$/
      add_to_cart(bot, callback_query, $1, user)
    when /^quantity_(\d+)_(-?\d+)$/
      update_quantity(bot, callback_query, $1, $2.to_i, user)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'back_to_categories'
      show_categories(bot, callback_query)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'show_cart'
      show_cart(bot, callback_query, user)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    end
  end

  def show_category_products(bot, callback_query, category_id)
    products = Product.where(category_id: category_id)
    category = Category.find(category_id)
    
    buttons = products.map do |product|
      [Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "#{product.name} — #{product.price} MDL",
        callback_data: "product_#{product.id}"
      )]
    end

    # Добавляем кнопку "Назад к категориям" в конец списка
    buttons << [Telegram::Bot::Types::InlineKeyboardButton.new(
      text: "⬅️ Назад к категориям",
      callback_data: "back_to_categories"
    )]
    
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    bot.api.send_message(
      chat_id: callback_query.from.id,
      text: "Выберите блюдо из категории #{category.name}:",
      reply_markup: markup
    )
  end

  def show_product_details(bot, callback_query, product_id)
    product = Product.find(product_id)
    user = User.find_by(telegram_id: callback_query.from.id)
    order = user.orders.find_or_create_by(status: 'cart')
    order_item = order.order_items.find_by(product: product)
    current_quantity = order_item&.quantity || 0
    
    buttons = []
    
    if current_quantity > 0
      # Если товар уже в корзине, показываем кнопки управления количеством
      quantity_buttons = [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: "➖", callback_data: "quantity_#{product.id}_-1"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: "#{current_quantity}", callback_data: "current_quantity"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: "➕", callback_data: "quantity_#{product.id}_1")
      ]
      buttons << quantity_buttons
    else
      # Если товара нет в корзине, показываем кнопку добавления
      add_button = Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "Добавить в корзину — #{product.price} MDL",
        callback_data: "add_to_cart_#{product.id}"
      )
      buttons << [add_button]
    end

    # Показываем кнопку корзины, если в ней есть товары
    if order.order_items.any?
      total_items = order.order_items.sum(:quantity)
      total_sum = order.order_items.sum('quantity * price')
      cart_button = Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "🛒 Корзина (#{total_items} шт. - #{total_sum} MDL)",
        callback_data: "show_cart"
      )
      buttons << [cart_button]
    end

    # Кнопка возврата к списку
    back_button = Telegram::Bot::Types::InlineKeyboardButton.new(
      text: "⬅️ Назад к списку",
      callback_data: "category_#{product.category_id}"
    )
    buttons << [back_button]
    
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    text = "#{product.name}\n\n#{product.description}\n\nЦена: #{product.price} MDL"
    
    # Проверяем, есть ли уже сообщение с этим продуктом
    begin
      bot.api.edit_message_caption(
        chat_id: callback_query.message.chat.id,
        message_id: callback_query.message.message_id,
        caption: text,
        reply_markup: markup
      )
    rescue
      if product.image_url
        bot.api.send_photo(
          chat_id: callback_query.from.id,
          photo: product.image_url,
          caption: text,
          reply_markup: markup
        )
      else
        bot.api.send_message(
          chat_id: callback_query.from.id,
          text: text,
          reply_markup: markup
        )
      end
    end
  end

  def update_quantity(bot, callback_query, product_id, change, user)
    product = Product.find(product_id)
    order = user.orders.find_or_create_by(status: 'cart')
    order_item = order.order_items.find_or_create_by(product: product) do |item|
      item.quantity = 0
      item.price = product.price
    end

    new_quantity = order_item.quantity + change
    
    if new_quantity <= 0
      order_item.destroy
      bot.api.answer_callback_query(
        callback_query_id: callback_query.id,
        text: "Товар удален из корзины"
      )
    else
      order_item.update(quantity: new_quantity)
      bot.api.answer_callback_query(
        callback_query_id: callback_query.id,
        text: "Количество изменено на #{new_quantity}"
      )
    end

    # Обновляем отображение продукта
    show_product_details(bot, callback_query, product_id)
  end

  def show_cart(bot, message_or_callback, user)
    order = user.orders.find_or_create_by(status: 'cart')
    
    chat_id = if message_or_callback.is_a?(Telegram::Bot::Types::CallbackQuery)
                message_or_callback.message.chat.id
              else
                message_or_callback.chat.id
              end

    if order.order_items.empty?
      bot.api.send_message(
        chat_id: chat_id,
        text: 'Ваша корзина пуста'
      )
      return
    end

    text = "Ваш заказ:\n\n"
    total = 0
    order.order_items.each do |item|
      subtotal = item.quantity * item.price
      total += subtotal
      text += "#{item.product.name} x#{item.quantity} = #{subtotal} MDL\n"
    end
    text += "\nИтого: #{total} MDL"

    buttons = [[
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: 'Оформить заказ',
        callback_data: 'checkout'
      )
    ]]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)

    bot.api.send_message(
      chat_id: chat_id,
      text: text,
      reply_markup: markup
    )
  end

  def show_contacts(bot, message)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "🏠 Наш адрес: [Адрес ресторана]\n📞 Телефон: [Номер телефона]\n⏰ Время работы: [Часы работы]"
    )
  end

  def add_to_cart(bot, callback_query, product_id, user)
    product = Product.find(product_id)
    order = user.orders.find_or_create_by(status: 'cart')
    quantity = 1 # Добавляем по одному
    
    order_item = order.order_items.find_or_create_by(product: product) do |item|
      item.quantity = 0
      item.price = product.price
    end
    order_item.update(quantity: order_item.quantity + quantity)

    bot.api.answer_callback_query(
      callback_query_id: callback_query.id,
      text: "#{product.name} добавлен в корзину"
    )

    # Обновляем отображение продукта
    show_product_details(bot, callback_query, product_id)
  end

  def handle_text_input(bot, message, user)
    # Здесь можно добавить обработку текстовых сообщений
    # например, для ввода адреса доставки или номера телефона
  end
end

# Создание и запуск бота
if __FILE__ == $0
  bot = SushiBot.new
  bot.start
end 