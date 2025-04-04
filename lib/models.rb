require 'active_record'
require 'dotenv/load'

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
    t.integer :telegram_id
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
  has_many :order_items
  has_many :products, through: :order_items

  def total_amount
    order_items.sum('quantity * price')
  end

  def paid?
    payment_status == 'success'
  end

  def process_payment_callback(payload, signature)
    return false unless payload['result']
    
    client = ENV['MAIB_TEST_MODE'] == 'true' ? MaibClientTest.new : MaibClient.new(
      ENV['MAIB_PROJECT_ID'],
      ENV['MAIB_PROJECT_SECRET'],
      ENV['MAIB_SIGNATURE_KEY']
    )

    return false unless client.verify_signature(payload, signature)

    update(
      payment_status: payload['result']['status'],
      status: payload['result']['status'] == 'success' ? 'paid' : 'payment_failed'
    )
  end
end

# Модель элемента заказа
class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
end 