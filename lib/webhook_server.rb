require 'sinatra'
require 'json'
require 'dotenv/load'
require_relative 'models'
require_relative 'bot'

class WebhookServer < Sinatra::Base
  post '/maib/callback' do
    content_type :json
    
    payload = JSON.parse(request.body.read)
    signature = request.env['HTTP_X_SIGNATURE']
    
    order = Order.find_by(payment_id: payload['result']['paymentId'])
    
    if order && order.process_payment_callback(payload, signature)
      if order.paid?
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
      end
      
      { status: 'ok' }.to_json
    else
      status 400
      { error: 'Invalid signature' }.to_json
    end
  end
end 