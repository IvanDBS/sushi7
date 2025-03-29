require 'dotenv/load'
require_relative 'models'
require_relative 'maib_client_test'
require_relative 'bot'

# Находим последний заказ в статусе checkout с payment_method = 'card'
order = Order.where(status: 'checkout', payment_method: 'card').order(created_at: :desc).first
unless order
  puts "Нет заказов для оплаты"
  exit
end

puts "Найден заказ ##{order.id} для пользователя #{order.user.first_name}"

# Создаем тестовый клиент
client = MaibClientTest.new

# Симулируем успешную оплату
callback_data, signature = client.simulate_payment_callback(order, 'success')

# Обрабатываем callback
if order.process_payment_callback(callback_data, signature)
  puts "Оплата успешно обработана!"
  
  # Отправляем уведомление админу
  bot = SushiBot.new
  Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot_client|
    # Формируем сообщение для админа
    admin_message = "🆕 Новый заказ!\n\n"
    admin_message += "🔢 ID заказа: #{order.id}\n"
    admin_message += "👤 Клиент: #{order.user.first_name}"
    admin_message += " (@#{order.user.username})" if order.user.username
    admin_message += "\n"
    admin_message += "📱 Телефон: #{order.phone}\n"
    admin_message += "📍 Адрес: #{order.address}\n"
    admin_message += "💭 Комментарий: #{order.comment}\n" if order.comment.present?
    admin_message += "💰 Оплата: Картой (оплачено)\n\n"
    admin_message += "📝 Заказ:\n"
    
    order.order_items.each do |item|
      admin_message += "- #{item.product.name} x#{item.quantity} = #{item.quantity * item.price} MDL\n"
    end
    
    admin_message += "\n💵 Итого: #{order.total_amount} MDL\n\n"
    
    # Создаем клавиатуру с кнопкой "Принять"
    keyboard = {
      inline_keyboard: [
        [{ text: "✅ Принять", callback_data: "accept_order_#{order.id}" }]
      ]
    }
    
    # Отправляем сообщение админу с кнопкой
    bot_client.api.send_message(
      chat_id: ENV['ADMIN_CHAT_ID'],
      text: admin_message,
      parse_mode: 'HTML',
      reply_markup: keyboard.to_json
    )
    
    # Отправляем сообщение клиенту
    bot_client.api.send_message(
      chat_id: order.user.telegram_id,
      text: "✅ Оплата получена! Ваш заказ ##{order.id} принят в обработку.\nМы свяжемся с вами для подтверждения."
    )
  end
  puts "Уведомления отправлены"
else
  puts "Ошибка при обработке оплаты"
end 