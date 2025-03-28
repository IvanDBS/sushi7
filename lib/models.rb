require 'active_record'

# Настройка подключения к базе данных
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.join(File.dirname(__FILE__), '../db/sushi_bot.sqlite3')
)

# Модель категории меню
class Category < ActiveRecord::Base
  has_many :products
end

# Модель продукта
class Product < ActiveRecord::Base
  belongs_to :category
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
end

# Модель элемента заказа
class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
end

# Создание таблиц, если они не существуют
ActiveRecord::Schema.define do
  create_table :categories, force: false do |t|
    t.string :name
    t.timestamps
  end

  create_table :products, force: false do |t|
    t.string :name
    t.text :description
    t.decimal :price
    t.references :category
    t.string :image_url
    t.timestamps
  end

  create_table :users, force: false do |t|
    t.integer :telegram_id
    t.string :first_name
    t.string :last_name
    t.string :phone_number
    t.timestamps
  end

  create_table :orders, force: false do |t|
    t.references :user
    t.string :status
    t.text :delivery_address
    t.decimal :total_amount
    t.timestamps
  end

  create_table :order_items, force: false do |t|
    t.references :order
    t.references :product
    t.integer :quantity
    t.decimal :price
    t.timestamps
  end
end 