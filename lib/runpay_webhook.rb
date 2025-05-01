require 'sinatra/base'
require 'json'
require 'openssl'
require_relative 'runpay_client'
require_relative 'models'
require_relative 'bot'

class RunPayWebhook < Sinatra::Base
  set :port, ENV['WEBHOOK_PORT'] || 4567
  set :bind, '0.0.0.0'

  def initialize
    super
    puts "RunPayWebhook initialized on port #{settings.port}"
    @runpay_client = RunPayClient.new
  end

  post '/webhook/runpay' do
    puts "Received RunPay webhook"
    payload = request.body.read
    puts "Payload: #{payload}"
    
    signature = request.env['HTTP_X_RUNPAY_SIGNATURE']
    puts "Signature: #{signature}"

    unless valid_signature?(payload, signature)
      puts "Invalid signature"
      status 401
      return 'Invalid signature'
    end

    data = JSON.parse(payload)
    puts "Processing webhook data: #{data.inspect}"
    process_webhook(data)

    status 200
    'OK'
  end

  private

  def valid_signature?(payload, signature)
    return false unless signature

    expected_signature = OpenSSL::HMAC.hexdigest(
      'sha256',
      ENV['RUNPAY_WEBHOOK_SECRET'],
      payload
    )

    puts "Expected signature: #{expected_signature}"
    puts "Received signature: #{signature}"

    Rack::Utils.secure_compare(signature, expected_signature)
  end

  def process_webhook(data)
    puts "Looking for order with payment_id: #{data['id']}"
    order = Order.find_by(payment_id: data['id'])
    
    unless order
      puts "Order not found!"
      return
    end

    puts "Found order: #{order.inspect}"

    case data['status']
    when 'Settled'
      puts "Payment settled, updating order status"
      order.update(status: 'paid', payment_status: 'success')
      notify_user_about_payment(order, :success)
    when 'Rejected', 'Cancelled'
      puts "Payment failed, updating order status"
      order.update(status: 'payment_failed', payment_status: 'failed')
      notify_user_about_payment(order, :failed)
    else
      puts "Unknown payment status: #{data['status']}"
    end
  end

  def notify_user_about_payment(order, status)
    puts "Sending notification to user #{order.user.telegram_id}"
    
    begin
      Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
        message = case status
        when :success
          Translations.t('payment_success', order.language)
        when :failed
          Translations.t('payment_failed', order.language)
        end

        # Уведомление пользователю
        bot.api.send_message(
          chat_id: order.user.telegram_id,
          text: message
        )

        if status == :success
          # Уведомление в админский чат
          admin_message = "🆕 Новый заказ (оплачен)!\n\n"
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
          
          admin_message += "\n💵 Итого: #{order.total_amount} MDL"
          admin_message += "\n🚚 Доставка: #{order.delivery_fee} MDL"
          admin_message += "\n💵 Итого с доставкой: #{order.total_with_delivery} MDL"

          keyboard = {
            inline_keyboard: [
              [{ text: "✅ Принять", callback_data: "accept_order_#{order.id}" }]
            ]
          }

          bot.api.send_message(
            chat_id: ENV['ADMIN_CHAT_ID'],
            text: admin_message,
            reply_markup: keyboard.to_json
          )
        end
      end
      puts "Notifications sent successfully"
    rescue => e
      puts "Error sending notifications: #{e.message}"
      puts e.backtrace
    end
  end
end 