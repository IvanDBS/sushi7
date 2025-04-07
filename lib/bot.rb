require 'telegram/bot'
require 'dotenv/load'
require_relative 'models'
require_relative 'scraper'
require_relative 'maib_client'
require_relative 'maib_client_test'
require_relative 'translations'
require_relative 'ingredients'
require_relative 'admin_commands'
require 'http'
require 'tempfile'

class SushiBot
  include AdminCommands

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
    # Сначала проверяем, не является ли это админской командой
    return if handle_admin_command(bot, message, user)

    case message.text
    when '/start'
      send_welcome_message(bot, message)
    else
      # Проверяем текст сообщения на соответствие переведенным строкам
      case message.text
      when Translations.t('menu', 'ru'), Translations.t('menu', 'ro'), Translations.t('menu', 'en')
        show_categories(bot, message)
      when Translations.t('cart', 'ru'), Translations.t('cart', 'ro'), Translations.t('cart', 'en')
        show_cart(bot, message, user)
      when Translations.t('settings', 'ru'), Translations.t('settings', 'ro'), Translations.t('settings', 'en')
        show_settings(bot, message)
      else
        handle_text_input(bot, message, user)
      end
    end
  end

  def send_welcome_message(bot, message)
    user = User.find_or_create_by(telegram_id: message.from.id)
    user.update(language: 'ru') if user.language.nil?

    keyboard = [
      [Telegram::Bot::Types::KeyboardButton.new(text: Translations.t('menu', user.language))],
      [Telegram::Bot::Types::KeyboardButton.new(text: Translations.t('cart', user.language))],
      [Telegram::Bot::Types::KeyboardButton.new(text: Translations.t('settings', user.language))]
    ]
    
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: keyboard,
      resize_keyboard: true
    )
    
    bot.api.send_message(
      chat_id: message.chat.id,
      text: Translations.t('welcome', user.language),
      reply_markup: markup
    )
  end

  def show_categories(bot, message_or_callback)
    user = User.find_by(telegram_id: message_or_callback.from.id)
    categories = Category.all
    buttons = categories.each_slice(2).map do |category_pair|
      category_pair.map do |category|
        translated_name = Translations::TRANSLATIONS[user.language.to_sym]&.dig(:categories, category.name) || category.name
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: translated_name,
          callback_data: "category_#{category.id}"
        )
      end
    end

    buttons << [Telegram::Bot::Types::InlineKeyboardButton.new(
      text: Translations.t('back_to_menu', user.language),
      callback_data: "back_to_categories"
    )]
    
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    chat_id = if message_or_callback.is_a?(Telegram::Bot::Types::CallbackQuery)
                message_or_callback.message.chat.id
              else
                message_or_callback.chat.id
              end

    if message_or_callback.is_a?(Telegram::Bot::Types::CallbackQuery)
      begin
        bot.api.edit_message_text(
          chat_id: chat_id,
          message_id: message_or_callback.message.message_id,
          text: "`#{Translations.t('select_category', user.language)}`",
          reply_markup: markup,
          parse_mode: 'Markdown'
        )
      rescue
        bot.api.send_message(
          chat_id: chat_id,
          text: "`#{Translations.t('select_category', user.language)}`",
          reply_markup: markup,
          parse_mode: 'Markdown'
        )
      end
    else
      bot.api.send_message(
        chat_id: chat_id,
        text: "`#{Translations.t('select_category', user.language)}`",
        reply_markup: markup,
        parse_mode: 'Markdown'
      )
    end
  end

  def show_settings(bot, message)
    user = User.find_by(telegram_id: message.from.id)
    
    # Создаем список доступных языков, исключая текущий
    available_languages = [
      { code: 'ru', name: '🇷🇺 Русский' },
      { code: 'ro', name: '🇷🇴 Română' },
      { code: 'en', name: '🇬🇧 English' }
    ].reject { |lang| lang[:code] == user.language }

    # Создаем кнопки для доступных языков
    buttons = []
    available_languages.each_slice(2) do |lang_pair|
      buttons << lang_pair.map do |lang|
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: lang[:name],
          callback_data: "lang_#{lang[:code]}"
        )
      end
    end

    # Добавляем кнопки контактов и доставки
    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: Translations.t('contacts_button', user.language),
        callback_data: 'show_contacts'
      ),
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: Translations.t('delivery_button', user.language),
        callback_data: 'show_delivery'
      )
    ]
    
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    bot.api.send_message(
      chat_id: message.chat.id,
      text: Translations.t('settings_text', user.language),
      reply_markup: markup
    )
  end

  def show_contacts(bot, callback_query)
    user = User.find_by(telegram_id: callback_query.from.id)
    bot.api.edit_message_text(
      chat_id: callback_query.message.chat.id,
      message_id: callback_query.message.message_id,
      text: Translations.t('contacts', user.language),
      parse_mode: 'Markdown'
    )
  end

  def show_delivery(bot, callback_query)
    user = User.find_by(telegram_id: callback_query.from.id)
    bot.api.edit_message_text(
      chat_id: callback_query.message.chat.id,
      message_id: callback_query.message.message_id,
      text: Translations.t('delivery', user.language),
      parse_mode: 'Markdown'
    )
  end

  def show_category_products(bot, callback_query, category_id)
    user = User.find_by(telegram_id: callback_query.from.id)
    products = Product.where(category_id: category_id)
    category = Category.find(category_id)
    
    # Для категории "Акции" показываем товары через связь many-to-many
    if category.name == '🏷️ Акции'
      products = Product.joins(:categories)
                      .where(categories: { id: category_id })
                      .where(is_sale: true)
    end
    
    buttons = products.map do |product|
      [Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "#{product.name} — #{product.price} MDL",
        callback_data: "product_#{product.id}"
      )]
    end

    buttons << [Telegram::Bot::Types::InlineKeyboardButton.new(
      text: Translations.t('back_to_menu', user.language),
      callback_data: "back_to_categories"
    )]
    
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    begin
      bot.api.edit_message_text(
        chat_id: callback_query.message.chat.id,
        message_id: callback_query.message.message_id,
        text: Translations.t('select_dish', user.language) % { category: category.name },
        reply_markup: markup
      )
    rescue
      bot.api.send_message(
        chat_id: callback_query.from.id,
        text: Translations.t('select_dish', user.language) % { category: category.name },
        reply_markup: markup
      )
    end
  end

  def valid_image_url?(url)
    return false unless url && url.is_a?(String)
    
    begin
      response = HTTP.head(url)
      if response.status.success? && response.mime_type.start_with?('image/')
        # Дополнительная проверка: пробуем загрузить изображение
        image_response = HTTP.get(url)
        image_response.status.success? && image_response.body.to_s.length > 0
      else
        false
      end
    rescue => e
      puts "Error checking image URL #{url}: #{e.message}"
      false
    end
  end

  def show_product_details(bot, callback_query, product_id)
    user = User.find_by(telegram_id: callback_query.from.id)
    product = Product.find(product_id)
    order = Order.find_or_create_by(user: user, status: 'cart')

    # Переводим описание продукта
    translated_description = translate_ingredients(product.description, user.language)

    # Формируем текст сообщения
    text = case user.language
    when 'ru'
      "#{product.name}\n\n#{translated_description}\n\nЦена: #{product.is_sale ? product.sale_price : product.price} MDL"
    when 'ro'
      "#{product.name}\n\n#{product.description}\n\nPreț: #{product.is_sale ? product.sale_price : product.price} MDL"
    when 'en'
      "#{product.name}\n\n#{translated_description}\n\nPrice: #{product.is_sale ? product.sale_price : product.price} MDL"
    end

    # Добавляем кнопки для управления количеством
    buttons = []
    
    # Находим существующий товар в корзине
    cart_item = order.order_items.find_by(product: product)
    
    if cart_item
      quantity = cart_item.quantity
      
      # Кнопки изменения количества
      buttons << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "➖",
          callback_data: "quantity_#{product.id}_-1"
        ),
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "#{quantity} шт.",
          callback_data: "dummy"
        ),
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "➕",
          callback_data: "quantity_#{product.id}_1"
        )
      ]
    else
      # Кнопка добавления в корзину
      add_text = case user.language
      when 'ru'
        "Добавить в корзину"
      when 'ro'
        "Adaugă în coș"
      when 'en'
        "Add to cart"
      end
      
      buttons << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: add_text,
          callback_data: "add_to_cart_#{product.id}"
        )
      ]
    end

    if order.order_items.any?
      total_items = order.order_items.sum(:quantity)
      total_sum = order.order_items.sum('quantity * price')
      
      # Переводим единицы измерения для корзины
      units = case user.language
      when 'ru'
        'шт.'
      when 'ro'
        'buc.'
      when 'en'
        'pcs.'
      end
      
      cart_button = Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "#{Translations.t('cart', user.language)} (#{total_items} #{units} - #{total_sum} MDL)",
        callback_data: "show_cart"
      )
      buttons << [cart_button]
    end

    # Get category name for back button
    category = product.category

    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: Translations.t('back_to_menu', user.language),
        callback_data: "back_to_categories"
      )
    ]
    
    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "🔙 Назад к #{category.name}",
        callback_data: "category_#{category.id}"
      )
    ]

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)

    # Отправляем сообщение с фото, если есть
    if product.image_url.present?
      begin
        bot.api.edit_message_media(
          chat_id: callback_query.message.chat.id,
          message_id: callback_query.message.message_id,
          media: Telegram::Bot::Types::InputMediaPhoto.new(
            media: product.image_url,
            caption: text
          ),
          reply_markup: markup
        )
      rescue => e
        puts "Ошибка при отправке фото: #{e.message}"
        # Если не удалось отправить фото, отправляем только текст
        bot.api.edit_message_text(
          chat_id: callback_query.message.chat.id,
          message_id: callback_query.message.message_id,
          text: text,
          reply_markup: markup
        )
      end
    else
      begin
        bot.api.edit_message_text(
          chat_id: callback_query.message.chat.id,
          message_id: callback_query.message.message_id,
          text: text,
          reply_markup: markup
        )
      rescue
        bot.api.send_message(
          chat_id: callback_query.from.id,
          text: text,
          reply_markup: markup
        )
      end
    end
  end

  def show_cart(bot, message_or_callback, user)
    order = user.orders.find_by(status: 'cart')
    
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
        text: Translations.t('cart_empty', user.language)
      )
      return
    end

    # Форматируем цену в зависимости от языка
    currency = case user.language
    when 'ru'
      'лей'
    when 'ro'
      'lei'
    when 'en'
      'MDL'
    end

    text = "#{Translations.t('cart', user.language)}:\n\n"
    buttons = []
    subtotal = 0

    # Фильтруем товары, которые все еще существуют в базе данных
    valid_items = order.order_items.select { |item| item.product.present? }
    
    # Если есть недействительные товары, удаляем их из корзины
    if valid_items.length < order.order_items.length
      invalid_items = order.order_items - valid_items
      invalid_items.each { |item| item.destroy }
    end

    valid_items.each do |item|
      item_total = item.quantity * item.price
      subtotal += item_total
      
      buttons << [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "#{item.product.name} - #{item.quantity} × #{item.price} = #{item_total} #{currency}",
          callback_data: "current_quantity"
        )
      ]
      
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

    # Добавляем информацию о доставке, если зона выбрана
    if order.delivery_zone
      zone_info = Order::DELIVERY_ZONES[order.delivery_zone][user.language]
      delivery_fee = order.delivery_fee
      text += "\n📍 #{zone_info[:name]}\n"
      if delivery_fee > 0
        text += Translations.t('delivery_fee', user.language) % { fee: "#{delivery_fee} #{currency}" }
        text += "\n#{Translations.t('free_delivery_threshold', user.language) % { threshold: "#{zone_info[:free_threshold]} #{currency}" }}\n"
      else
        text += Translations.t('free_delivery', user.language) + "\n"
      end
    end

    text += "\n#{Translations.t('cart_total', user.language) % { total: "#{order.total_with_delivery} #{currency}" }}"

    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: Translations.t('checkout', user.language),
        callback_data: 'checkout'
      )
    ]
    buttons << [
      Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "🔙 #{Translations.t('back_to_menu', user.language)}",
        callback_data: 'back_to_categories'
      )
    ]

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)

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

  def start_checkout(bot, callback_query, user)
    order = user.orders.find_by(status: 'cart')
    return unless order

    user.orders.where(status: ['cart', 'checkout']).where.not(id: order.id).update_all(status: 'cancelled')
    order.update(status: 'checkout', checkout_step: 'delivery_zone')
    
    show_delivery_zones(bot, callback_query.message.chat.id, user)
  end

  def show_delivery_zones(bot, chat_id, user)
    order = user.orders.find_by(status: 'checkout')
    buttons = Order::DELIVERY_ZONES.map do |zone_key, zone_info|
      # Add green checkmark if this zone is selected
      checkmark = order&.delivery_zone == zone_key ? "✅ " : ""
      
      # Calculate delivery fee based on order total
      fee = if order&.total && order.total >= zone_info[user.language][:free_threshold]
        0
      else
        zone_info[user.language][:fee]
      end
      
      [Telegram::Bot::Types::InlineKeyboardButton.new(
        text: "#{checkmark}#{zone_info[user.language][:name]} (#{fee} #{user.language == 'ru' ? 'лей' : user.language == 'ro' ? 'lei' : 'MDL'})",
        callback_data: "delivery_zone_#{zone_key}"
      )]
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    bot.api.send_message(
      chat_id: chat_id,
      text: Translations.t('select_delivery_zone', user.language),
      reply_markup: markup
    )
  end

  def handle_delivery_zone(bot, callback_query, user, zone)
    order = user.orders.find_by(status: 'checkout')
    return unless order

    order.update(delivery_zone: zone, checkout_step: 'phone')
    
    # Show updated delivery zones with checkmark
    show_delivery_zones(bot, callback_query.message.chat.id, user)
    
    # Then ask for phone number
    bot.api.send_message(
      chat_id: callback_query.message.chat.id,
      text: Translations.t('enter_phone', user.language)
    )
  end

  def ask_for_address(bot, chat_id)
    user = User.find_by(telegram_id: chat_id)
    bot.api.send_message(
      chat_id: chat_id,
      text: Translations.t('enter_address', user.language)
    )
  end

  def ask_for_comment(bot, chat_id)
    user = User.find_by(telegram_id: chat_id)
    bot.api.send_message(
      chat_id: chat_id,
      text: Translations.t('enter_comment', user.language)
    )
  end

  def show_payment_methods(bot, chat_id)
    user = User.find_by(telegram_id: chat_id)
    buttons = [
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: Translations.t('cash_payment', user.language),
          callback_data: "payment_cash"
        )
      ],
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: Translations.t('card_payment', user.language),
          callback_data: "payment_card"
        )
      ]
    ]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttons)
    
    bot.api.send_message(
      chat_id: chat_id,
      text: Translations.t('select_payment', user.language),
      reply_markup: markup
    )
  end

  def complete_order(bot, callback_query, order)
    user = User.find_by(telegram_id: callback_query.from.id)
    admin_message = "Новый заказ!\n\n"
    admin_message += "🔢 ID заказа: #{order.id}\n"
    admin_message += "👤 Клиент: #{callback_query.from.first_name}"
    admin_message += " #{callback_query.from.last_name}" if callback_query.from.last_name
    admin_message += " (@#{callback_query.from.username})" if callback_query.from.username
    admin_message += "\n"
    admin_message += "📱 Телефон: #{order.phone}\n"
    
    # Add delivery zone information
    zone_info = Order::DELIVERY_ZONES[order.delivery_zone][user.language]
    admin_message += "📍 Регион доставки: #{zone_info[:name]}\n"
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
    
    # Add delivery fee and total with delivery
    delivery_fee = order.delivery_fee
    total_with_delivery = total + delivery_fee
    admin_message += "\n💵 Сумма заказа: #{total} MDL"
    admin_message += "\n🚚 Доставка: #{delivery_fee} MDL"
    admin_message += "\n💵 Итого с доставкой: #{total_with_delivery} MDL"

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

    bot.api.send_message(
      chat_id: @admin_chat_id,
      text: admin_message,
      reply_markup: markup,
      parse_mode: 'HTML'
    )

    bot.api.send_message(
      chat_id: callback_query.message.chat.id,
      text: Translations.t('order_success', user.language)
    )

    order.update(status: 'pending')
    close_old_carts(user)
    user.orders.create(status: 'cart')
  end

  def handle_order_acceptance(bot, callback_query, order_id, accepted)
    order = Order.find(order_id)
    return unless order

    new_status = accepted ? 'accepted' : 'rejected'
    order.update(status: new_status)

    message = if accepted
      Translations.t('order_accepted', order.user.language)
    else
      Translations.t('order_rejected', order.user.language)
    end

    bot.api.send_message(
      chat_id: order.user.telegram_id,
      text: message
    )

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

    if !accepted
      close_old_carts(order.user)
      order.user.orders.create(status: 'cart')
    end
  end

  def change_language(bot, callback_query, user, lang)
    user.update(language: lang)
    
    text = case lang
    when 'ru'
      "🇷🇺 Язык изменен на Русский"
    when 'ro'
      "🇷🇴 Limba a fost schimbată în Română"
    when 'en'
      "🇬🇧 Language changed to English"
    end
    
    bot.api.edit_message_text(
      chat_id: callback_query.message.chat.id,
      message_id: callback_query.message.message_id,
      text: text
    )

    # Обновляем клавиатуру после смены языка
    keyboard = [
      [Telegram::Bot::Types::KeyboardButton.new(text: Translations.t('menu', lang))],
      [Telegram::Bot::Types::KeyboardButton.new(text: Translations.t('cart', lang))],
      [Telegram::Bot::Types::KeyboardButton.new(text: Translations.t('settings', lang))]
    ]
    
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: keyboard,
      resize_keyboard: true
    )
    
    bot.api.send_message(
      chat_id: callback_query.message.chat.id,
      text: Translations.t('welcome', lang),
      reply_markup: markup
    )
  end

  def handle_text_input(bot, message, user)
    order = user.orders.find_by(status: 'checkout')
    
    if order
      case order.checkout_step
      when 'phone'
        order.update(phone: message.text, checkout_step: 'address')
        ask_for_address(bot, message.chat.id)
      when 'address'
        order.update(address: message.text, checkout_step: 'comment')
        ask_for_comment(bot, message.chat.id)
      when 'comment'
        order.update(comment: message.text)
        show_payment_methods(bot, message.chat.id)
      end
    else
      show_categories(bot, message)
    end
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
    when 'show_contacts'
      show_contacts(bot, callback_query)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when 'show_delivery'
      show_delivery(bot, callback_query)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when /^lang_(ru|ro|en)$/
      change_language(bot, callback_query, user, $1)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    when /^delivery_zone_(chisinau|suburbs)$/
      handle_delivery_zone(bot, callback_query, user, $1)
      bot.api.answer_callback_query(callback_query_id: callback_query.id)
    end
  end

  def add_to_cart(bot, callback_query, product_id, user)
    product = Product.find(product_id)
    order = user.orders.find_or_create_by(status: 'cart')
    order_item = order.order_items.find_or_create_by(product: product) do |item|
      item.quantity = 1
      item.price = product.is_sale ? product.sale_price : product.price
    end

    bot.api.answer_callback_query(
      callback_query_id: callback_query.id,
      text: Translations.t('item_added', user.language)
    )

    show_product_details(bot, callback_query, product_id)
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
        text: Translations.t('item_removed', user.language)
      )
    else
      order_item.update(quantity: new_quantity)
      bot.api.answer_callback_query(
        callback_query_id: callback_query.id,
        text: Translations.t('quantity_updated', user.language) % { quantity: new_quantity }
      )
    end

    show_product_details(bot, callback_query, product_id)
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
        text: Translations.t('item_removed', user.language)
      )
    else
      order_item.update(quantity: new_quantity)
      bot.api.answer_callback_query(
        callback_query_id: callback_query.id,
        text: Translations.t('quantity_updated', user.language) % { quantity: new_quantity }
      )
    end

    show_cart(bot, callback_query, user)
  end

  def close_old_carts(user)
    user.orders.where(status: 'cart').update_all(status: 'abandoned')
  end

  def handle_payment_method(bot, callback_query, user)
    order = user.orders.find_by(status: 'checkout')
    return unless order
    
    payment_method = callback_query.data.split('_').last
    order.update(payment_method: payment_method)
    
    if payment_method == 'cash'
      complete_order(bot, callback_query, order)
    else
      bot.api.send_message(
        chat_id: callback_query.message.chat.id,
        text: Translations.t('card_payment_unavailable', user.language)
      )
    end
  end

  def translate_ingredients(description, language)
    # Заменяем единицы измерения
    description = description.gsub(/(\d+)\s*buc\.?/i) do |match|
      Ingredients.units($1, language)
    end

    # Заменяем граммы и миллилитры
    description = description.gsub(/(\d+)(?:g|gr|г)/i) do |match|
      Ingredients.grams($1, language)
    end

    description = description.gsub(/(\d+)\s*ml/i) do |match|
      Ingredients.milliliters($1, language)
    end

    # Заменяем формат цены
    description = description.gsub(/PREȚ\s*[-–]\s*(\d+(?:\.\d+)?)\s*(?:MDL|lei)/i) do |match|
      price = $1
      Ingredients.price_format(price, language)
    end

    # Заменяем ингредиенты, но пропускаем названия блюд в сетах и роллах
    ingredients = Ingredients.all

    if language == 'ru'
      ingredients['ru'].each do |rom, rus|
        # Пропускаем перевод, если это часть названия блюда в сете или ролле
        next if description.match?(/\b(?:set|сет|seturi|roll|ролл|maki|маки|nigiri|нигири|gunkan|гункан)\b/i) && 
                description.match?(/\b#{rom}\b/i)
        description = description.gsub(/\b#{rom}\b/i, rus)
      end
    elsif language == 'en'
      ingredients['en'].each do |rom, eng|
        # Пропускаем перевод, если это часть названия блюда в сете или ролле
        next if description.match?(/\b(?:set|сет|seturi|roll|ролл|maki|маки|nigiri|нигири|gunkan|гункан)\b/i) && 
                description.match?(/\b#{rom}\b/i)
        description = description.gsub(/\b#{rom}\b/i, eng)
      end
    end

    # Делаем первое слово с заглавной буквы
    description = description.strip
    if description.length > 0
      description[0] = description[0].upcase
    end

    description
  end
end

# Создание и запуск бота
if __FILE__ == $0
  bot = SushiBot.new
  bot.start
end 