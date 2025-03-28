require 'telegram/bot'
require 'dotenv/load'
require_relative 'models'
require_relative 'scraper'

class SushiBot
  def initialize
    @token = ENV['TELEGRAM_BOT_TOKEN']
    @admin_chat_id = ENV['ADMIN_CHAT_ID']
  end

  def start
    Telegram::Bot::Client.run(@token) do |bot|
      puts 'Бот запущен'
      
      bot.listen do |message|
        begin
          user = User.find_or_create_by(telegram_id: message.from.id) do |u|
            u.first_name = message.from.first_name
            u.last_name = message.from.last_name
          end

          case message
          when Telegram::Bot::Types::Message
            handle_message(bot, message, user)
          when Telegram::Bot::Types::CallbackQuery
            handle_callback(bot, message, user)
          end
        rescue => e
          puts "Ошибка: #{e.message}"
          bot.api.send_message(
            chat_id: message.from.id,
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

  def show_categories(bot, message)
    categories = Category.all
    buttons = categories.map do |category|
      [Telegram::Bot::Types::InlineKeyboardButton.new(
        text: category.name,
        callback_data: "category_#{category.id}"
      )]
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: 'Выберите категорию:',
      reply_markup: markup
    )
  end

  def handle_callback(bot, callback_query, user)
    case callback_query.data
    when /^category_(\d+)$/
      show_category_products(bot, callback_query, $1)
    when /^product_(\d+)$/
      show_product_details(bot, callback_query, $1)
    when /^add_to_cart_(\d+)$/
      add_to_cart(bot, callback_query, $1, user)
    end
  end

  def show_category_products(bot, callback_query, category_id)
    products = Product.where(category_id: category_id)
    products.each do |product|
      buttons = [[
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "Добавить в корзину (#{product.price} MDL)",
          callback_data: "add_to_cart_#{product.id}"
        )
      ]]
      
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
      
      bot.api.send_photo(
        chat_id: callback_query.from.id,
        photo: product.image_url,
        caption: "#{product.name}\n#{product.description}\nЦена: #{product.price} MDL",
        reply_markup: markup
      )
    end
  end

  def show_cart(bot, message, user)
    order = user.orders.find_or_create_by(status: 'cart')
    if order.order_items.empty?
      bot.api.send_message(
        chat_id: message.chat.id,
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
      chat_id: message.chat.id,
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
    
    order_item = order.order_items.find_or_create_by(product: product) do |item|
      item.quantity = 0
      item.price = product.price
    end
    order_item.update(quantity: order_item.quantity + 1)

    bot.api.answer_callback_query(
      callback_query_id: callback_query.id,
      text: "#{product.name} добавлен в корзину"
    )
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