require 'active_record'
require 'dotenv/load'
require_relative 'runpay_client'

# Database configuration
db_config = {
  adapter: 'postgresql',
  host: ENV.fetch('POSTGRES_HOST', 'localhost'),
  database: ENV.fetch('POSTGRES_DATABASE', 'sushi7_development'),
  username: ENV.fetch('POSTGRES_USER', 'postgres'),
  password: ENV.fetch('POSTGRES_PASSWORD', '')
}

# Setup database connection
ActiveRecord::Base.establish_connection(db_config)

# Create tables if they don't exist
ActiveRecord::Schema.define do
  # Only create tables if they don't exist
  create_table :categories, if_not_exists: true do |t|
    t.string :name
    t.string :url_name
    t.timestamps
  end

  create_table :products, if_not_exists: true do |t|
    t.string :name
    t.text :description
    t.decimal :price, precision: 10, scale: 2
    t.string :image_url
    t.references :category, foreign_key: true
    t.boolean :is_sale, default: false
    t.decimal :sale_price, precision: 10, scale: 2
    t.decimal :original_price, precision: 10, scale: 2
    t.timestamps
  end

  create_table :product_categories, if_not_exists: true do |t|
    t.references :product
    t.references :category
    t.timestamps
  end

  create_table :users, if_not_exists: true do |t|
    t.bigint :telegram_id
    t.string :first_name
    t.string :last_name
    t.string :username
    t.string :language, default: 'ru'
    t.timestamps
  end

  create_table :orders, if_not_exists: true do |t|
    t.references :user
    t.string :status
    t.string :phone
    t.string :address
    t.text :comment
    t.string :payment_method
    t.string :checkout_step
    t.string :payment_id
    t.string :payment_status
    t.timestamps
  end

  create_table :order_items, if_not_exists: true do |t|
    t.references :order
    t.references :product
    t.integer :quantity
    t.decimal :price
    t.timestamps
  end
end

# Модель категории меню
class Category < ActiveRecord::Base
  has_many :products
  has_and_belongs_to_many :products, join_table: :product_categories
end

# Модель продукта
class Product < ActiveRecord::Base
  belongs_to :category
  has_and_belongs_to_many :categories, join_table: :product_categories
  has_many :order_items
end

# Модель пользователя
class User < ActiveRecord::Base
  has_many :orders
end

# Модель заказа
class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  DELIVERY_ZONES = {
    'chisinau' => {
      'ru' => { name: 'Кишинев', fee: 50, free_threshold: 500 },
      'ro' => { name: 'Chișinău', fee: 50, free_threshold: 500 },
      'en' => { name: 'Chisinau', fee: 50, free_threshold: 500 }
    },
    'suburbs' => {
      'ru' => { name: 'Пригород', fee: 80, free_threshold: 800 },
      'ro' => { name: 'Suburbii', fee: 80, free_threshold: 800 },
      'en' => { name: 'Suburbs', fee: 80, free_threshold: 800 }
    }
  }

  def delivery_fee
    return 0 if delivery_zone.nil?
    zone_info = DELIVERY_ZONES[delivery_zone][user.language]
    total = order_items.sum('quantity * price')
    total >= zone_info[:free_threshold] ? 0 : zone_info[:fee]
  end

  def total_with_delivery
    order_items.sum('quantity * price') + delivery_fee
  end

  def total_amount
    order_items.sum('quantity * price')
  end

  def create_payment
    client = RunPayClient.new
    
    amount = total_with_delivery
    
    result = client.create_invoice(
      invoice: {
        description: "Order ##{id}",
        orderId: id.to_s
      },
      amount: {
        value: amount,
        currency: "MDL"
      },
      paymentMethod: "BANKCARD"
    )
    
    if result && result["url"]
      update(
        payment_id: result["paymentId"],
        payment_status: "pending"
      )
      result["url"]
    else
      nil
    end
  end

  def process_payment_callback(payload)
    return false unless payload['orderId'] == id.to_s
    return false unless payload['merchantId'] == ENV['RUNPAY_MERCHANT_ID']
    
    # Verify amount
    expected_amount = (total_with_delivery * 100).to_i
    return false unless payload['amount'] && 
                       payload['amount']['value'].to_i == expected_amount &&
                       payload['amount']['currency'] == 'MDL'

    new_status = case payload['status']
                 when 'Settled'
                   'success'
                 when 'Authorized'
                   'authorized'
                 when 'Cancelled', 'Rejected'
                   'failed'
                 else
                   'pending'
                 end

    # Add _test suffix for test payments
    payment_status_value = ENV['RUNPAY_TEST_MODE'] == 'true' ? "#{new_status}_test" : new_status

    update(
      payment_status: payment_status_value,
      status: new_status == 'success' ? 'paid' : 'payment_failed'
    )

    true
  end

  def paid?
    payment_status == 'success'
  end

  def total
    order_items.sum('quantity * price')
  end

  def language
    user.language
  end

  def check_payment_status
    return unless payment_id && payment_status == 'pending'
    
    client = RunPayClient.new
    result = client.get_payment_status(payment_id)
    
    if result['status'] == 'success' && result['payment']
      case result['payment']['status']
      when 'Settled'
        update(status: 'paid', payment_status: 'success')
        notify_about_payment(:success)
      when 'Rejected', 'Cancelled'
        update(status: 'payment_failed', payment_status: 'failed')
        notify_about_payment(:failed)
      end
    end
  end

  def notify_about_payment(status)
    Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
      message = case status
      when :success
        Translations.t('payment_success', language)
      when :failed
        Translations.t('payment_failed', language)
      end

      # Уведомление пользователю
      bot.api.send_message(
        chat_id: user.telegram_id,
        text: message
      )

      if status == :success
        # Уведомление в админский чат
        admin_message = "🆕 Новый заказ (оплачен)!\n\n"
        admin_message += "🔢 ID заказа: #{id}\n"
        admin_message += "👤 Клиент: #{user.first_name}"
        admin_message += " (@#{user.username})" if user.username
        admin_message += "\n"
        admin_message += "📱 Телефон: #{phone}\n"
        admin_message += "📍 Адрес: #{address}\n"
        admin_message += "💭 Комментарий: #{comment}\n" if comment.present?
        admin_message += "💰 Оплата: Картой (оплачено)\n\n"
        admin_message += "📝 Заказ:\n"
        
        order_items.each do |item|
          admin_message += "- #{item.product.name} x#{item.quantity} = #{item.quantity * item.price} MDL\n"
        end
        
        admin_message += "\n💵 Итого: #{total_amount} MDL"
        admin_message += "\n🚚 Доставка: #{delivery_fee} MDL"
        admin_message += "\n💵 Итого с доставкой: #{total_with_delivery} MDL"

        keyboard = {
          inline_keyboard: [
            [{ text: "✅ Принять", callback_data: "accept_order_#{id}" }]
          ]
        }

        bot.api.send_message(
          chat_id: ENV['ADMIN_CHAT_ID'],
          text: admin_message,
          reply_markup: keyboard.to_json
        )
      end
    end
  end
end

# Модель элемента заказа
class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
end 