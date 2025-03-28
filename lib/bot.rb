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
    when /^cart_quantity_(\d+)_(-?\d+)$/
      update_cart_quantity(bot, callback_query, $1, $2.to_i, user)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'back_to_categories'
      show_categories(bot, callback_query)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'show_cart'
      show_cart(bot, callback_query, user)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'checkout'
      start_checkout(bot, callback_query, user)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'payment_cash', 'payment_card'
      handle_payment_method(bot, callback_query, user)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when /^accept_order_(\d+)$/
      handle_order_acceptance(bot, callback_query, $1, true) if callback_query.message.chat.id.to_s == @admin_chat_id
    when /^reject_order_(\d+)$/
      handle_order_acceptance(bot, callback_query, $1, false) if callback_query.message.chat.id.to_s == @admin_chat_id
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
    # Находим существующую корзину
    order = user.orders.find_by(status: 'cart')
    
    # Если корзины нет, закрываем старые и создаем новую
    if order.nil?
      close_old_carts(user)
      order = user.orders.create(status: 'cart')
    end
    
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

    text = "🛒 Ваша корзина:\n\n"
    buttons = []
    total = 0

    # Формируем список товаров
    order.order_items.each do |item|
      subtotal = item.quantity * item.price
      total += subtotal
      
      # Добавляем название товара как кнопку
      buttons << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "#{item.product.name} - #{item.quantity} x #{item.price} = #{subtotal} MDL",
          callback_data: "current_quantity"
        )
      ]
      
      # Добавляем кнопки управления количеством
      buttons << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "➖",
          callback_data: "cart_quantity_#{item.product.id}_-1"
        ),
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: item.quantity.to_s,
          callback_data: "current_quantity"
        ),
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "➕",
          callback_data: "cart_quantity_#{item.product.id}_1"
        )
      ]
    end

    text += "💵 Итого: #{total} MDL"

    # Добавляем кнопки действий
    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: '✅ Оформить заказ',
        callback_data: 'checkout'
      )
    ]
    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: '⬅️ Вернуться в меню',
        callback_data: 'back_to_categories'
      )
    ]

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)

    # Пытаемся обновить существующее сообщение, если это callback
    if message_or_callback.is_a?(Telegram::Bot::Types::CallbackQuery)
      begin
        bot.api.edit_message_text(
          chat_id: chat_id,
          message_id: message_or_callback.message.message_id,
          text: text,
          reply_markup: markup,
          parse_mode: 'HTML'
        )
      rescue
        bot.api.send_message(
          chat_id: chat_id,
          text: text,
          reply_markup: markup,
          parse_mode: 'HTML'
        )
      end
    else
      bot.api.send_message(
        chat_id: chat_id,
        text: text,
        reply_markup: markup,
        parse_mode: 'HTML'
      )
    end
  end

  def show_contacts(bot, message)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "📍 Адрес:\nStr. Mitropolit Gavriil Bănulescu-Bodoni 57\n\n" \
            "📞 Телефон:\n061 061 111\n\n" \
            "📧 E-mail:\noffice@ohmysushi.md\n\n" \
            "⏰ Время работы:\n12:00 – 00:00"
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
    order = user.orders.find_by(status: 'checkout')
    return unless order

    case order.checkout_step
    when 'phone'
      if message.text.match?(/^\+?\d{8,15}$/)
        order.update(phone: message.text, checkout_step: 'address')
        ask_for_address(bot, message.chat.id)
      else
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Пожалуйста, введите корректный номер телефона"
        )
      end
    when 'address'
      if message.text.length >= 5
        order.update(address: message.text, checkout_step: 'comment')
        ask_for_comment(bot, message.chat.id)
      else
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Пожалуйста, введите более подробный адрес"
        )
      end
    when 'comment'
      order.update(comment: message.text, checkout_step: 'payment')
      show_payment_methods(bot, message.chat.id)
    end
  end

  def start_checkout(bot, callback_query, user)
    order = user.orders.find_by(status: 'cart')
    return unless order&.order_items&.any?

    # Переводим заказ в статус оформления
    order.update(status: 'checkout', checkout_step: 'phone')
    
    # Запрашиваем телефон
    bot.api.send_message(
      chat_id: callback_query.message.chat.id,
      text: "Для оформления заказа, пожалуйста, введите ваш номер телефона:"
    )
  end

  def ask_for_address(bot, chat_id)
    bot.api.send_message(
      chat_id: chat_id,
      text: "Теперь введите адрес доставки:"
    )
  end

  def ask_for_comment(bot, chat_id)
    bot.api.send_message(
      chat_id: chat_id,
      text: "Добавьте комментарий к заказу (или отправьте '-' чтобы пропустить):"
    )
  end

  def show_payment_methods(bot, chat_id)
    buttons = [
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "💵 Наличными при получении",
          callback_data: "payment_cash"
        )
      ],
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "💳 Оплата картой",
          callback_data: "payment_card"
        )
      ]
    ]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    bot.api.send_message(
      chat_id: chat_id,
      text: "Выберите способ оплаты:",
      reply_markup: markup
    )
  end

  def handle_payment_method(bot, callback_query, user)
    order = user.orders.find_by(status: 'checkout')
    return unless order

    payment_method = callback_query.data.split('_').last
    order.update(payment_method: payment_method)

    if payment_method == 'cash'
      complete_order(bot, callback_query, order)
    else
      # В будущем здесь будет логика для оплаты картой
      bot.api.send_message(
        chat_id: callback_query.message.chat.id,
        text: "⚠️ Оплата картой временно недоступна. Пожалуйста, выберите оплату наличными."
      )
      show_payment_methods(bot, callback_query.message.chat.id)
    end
  end

  def complete_order(bot, callback_query, order)
    # Формируем сообщение для админа
    admin_message = "🆕 Новый заказ!\n\n"
    admin_message += "🔢 ID заказа: #{order.id}\n"
    admin_message += "👤 Клиент: #{callback_query.from.first_name}"
    admin_message += " #{callback_query.from.last_name}" if callback_query.from.last_name
    admin_message += " (@#{callback_query.from.username})" if callback_query.from.username
    admin_message += "\n"
    admin_message += "📱 Телефон: #{order.phone}\n"
    admin_message += "📍 Адрес: #{order.address}\n"
    admin_message += "💭 Комментарий: #{order.comment}\n" if order.comment.present? && order.comment != '-'
    admin_message += "💰 Оплата: #{order.payment_method == 'cash' ? 'Наличными при получении' : 'Картой'}\n\n"
    admin_message += "📝 Заказ:\n"
    
    total = 0
    order.order_items.each do |item|
      subtotal = item.quantity * item.price
      total += subtotal
      admin_message += "- #{item.product.name} x#{item.quantity} = #{subtotal} MDL\n"
    end
    admin_message += "\n💵 Итого: #{total} MDL"

    # Добавляем кнопки для админа
    buttons = [
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: '✅ Принять заказ',
          callback_data: "accept_order_#{order.id}"
        ),
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: '❌ Отклонить заказ',
          callback_data: "reject_order_#{order.id}"
        )
      ]
    ]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)

    # Отправляем сообщение админу
    bot.api.send_message(
      chat_id: @admin_chat_id,
      text: admin_message,
      reply_markup: markup,
      parse_mode: 'HTML'
    )

    # Отправляем подтверждение пользователю
    bot.api.send_message(
      chat_id: callback_query.message.chat.id,
      text: "✅ Ваш заказ успешно оформлен!\n\nМы свяжемся с вами в ближайшее время для подтверждения заказа.\n\nСпасибо, что выбрали Oh! My Sushi! 🍣"
    )

    # Создаем новую пустую корзину для пользователя
    order.update(status: 'pending')
    user = User.find_by(telegram_id: callback_query.from.id)
    close_old_carts(user)
    user.orders.create(status: 'cart')
  end

  def handle_order_acceptance(bot, callback_query, order_id, accepted)
    order = Order.find(order_id)
    return unless order

    # Обновляем статус заказа
    new_status = accepted ? 'accepted' : 'rejected'
    order.update(status: new_status)

    # Отправляем сообщение клиенту
    message = if accepted
      "✅ Ваш заказ принят и готовится!\n\nОжидайте доставку в течение 60-90 минут.\n\nПриятного аппетита! 🍣"
    else
      "❌ К сожалению, ваш заказ отклонен.\n\n" \
      "Приносим извинения за неудобства.\n" \
      "Пожалуйста, попробуйте оформить заказ позже или свяжитесь с нами:\n\n" \
      "⏰ Время работы: 12:00 – 00:00\n" \
      "📞 Телефон: 061 061 111"
    end

    bot.api.send_message(
      chat_id: order.user.telegram_id,
      text: message
    )

    # Обновляем сообщение в админке
    admin_message = callback_query.message.text + "\n\n"
    admin_message += accepted ? "✅ Заказ принят" : "❌ Заказ отклонен"

    bot.api.edit_message_text(
      chat_id: @admin_chat_id,
      message_id: callback_query.message.message_id,
      text: admin_message
    )

    bot.api.answer_callback_query(
      callback_query_id: callback_query.id,
      text: accepted ? "Заказ ##{order.id} принят" : "Заказ ##{order.id} отклонен"
    )

    # Создаем новую корзину только если заказ отклонен
    if !accepted
      close_old_carts(order.user)
      order.user.orders.create(status: 'cart')
    end
  end

  def update_cart_quantity(bot, callback_query, product_id, change, user)
    order = user.orders.find_by(status: 'cart')
    return unless order

    product = Product.find(product_id)
    order_item = order.order_items.find_by(product: product)
    return unless order_item

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

    # Обновляем отображение корзины
    show_cart(bot, callback_query, user)
  end

  def close_old_carts(user)
    # Закрываем все старые корзины пользователя
    user.orders.where(status: 'cart').update_all(status: 'abandoned')
  end
end

# Создание и запуск бота
if __FILE__ == $0
  bot = SushiBot.new
  bot.start
end 