module AdminCommands
  def admin?(user_id)
    user_id.to_s == ENV['ADMIN_TELEGRAM_ID']
  end

  def handle_admin_command(bot, message, user)
    return unless admin?(message.from.id)

    case message.text
    when '/list_products'
      list_products(bot, message)
    when /^\/find_product (.+)/
      find_product(bot, message, $1)
    when /^\/product_info (\d+)/
      show_product_info(bot, message, $1)
    when /^\/edit_price (\d+) (\d+\.?\d*)/
      edit_price(bot, message, $1, $2)
    when /^\/set_sale (\d+) (\d+\.?\d*)/
      set_sale(bot, message, $1, $2)
    when /^\/remove_sale (\d+)/
      remove_sale(bot, message, $1)
    when '/sale_products'
      list_sale_products(bot, message)
    end
  end

  private

  def list_products(bot, message)
    products = Product.all
    text = "Список всех товаров:\n\n"
    
    products.each do |product|
      sale_info = if product.is_sale
        "(Акция: #{product.sale_price} MDL)"
      else
        ""
      end
      
      text += "ID: #{product.id} | #{product.name} | #{product.price} MDL #{sale_info}\n"
    end
    
    # Разбиваем на части, если сообщение слишком длинное
    text.scan(/.{1,4000}/m) do |chunk|
      bot.api.send_message(
        chat_id: message.chat.id,
        text: chunk
      )
    end
  end

  def find_product(bot, message, query)
    products = Product.where("name ILIKE ?", "%#{query}%")
    
    if products.empty?
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Товары не найдены."
      )
      return
    end

    text = "Найденные товары:\n\n"
    products.each do |product|
      sale_info = if product.is_sale
        "(Акция: #{product.sale_price} MDL)"
      else
        ""
      end
      
      text += "ID: #{product.id} | #{product.name} | #{product.price} MDL #{sale_info}\n"
    end

    bot.api.send_message(
      chat_id: message.chat.id,
      text: text
    )
  end

  def show_product_info(bot, message, product_id)
    product = Product.find(product_id)
    
    text = "Информация о товаре:\n\n"
    text += "ID: #{product.id}\n"
    text += "Название: #{product.name}\n"
    text += "Категория: #{product.category.name}\n"
    text += "Описание: #{product.description}\n"
    text += "Обычная цена: #{product.price} MDL\n"
    
    if product.is_sale
      text += "Акционная цена: #{product.sale_price} MDL\n"
      text += "Скидка: #{((1 - product.sale_price / product.price) * 100).round(1)}%\n"
    end

    bot.api.send_message(
      chat_id: message.chat.id,
      text: text
    )
  end

  def edit_price(bot, message, product_id, new_price)
    product = Product.find(product_id)
    old_price = product.price
    
    product.update(
      price: new_price.to_f,
      original_price: new_price.to_f,
      sale_price: new_price.to_f
    )

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "✅ Цена товара \"#{product.name}\" изменена:\n#{old_price} MDL ➡️ #{new_price} MDL"
    )
  end

  def set_sale(bot, message, product_id, sale_price)
    product = Product.find(product_id)
    sale_category = Category.find_by(name: '🏷️ Акции')
    
    if sale_price.to_f >= product.price
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "❌ Акционная цена должна быть ниже обычной цены (#{product.price} MDL)"
      )
      return
    end

    product.update(
      is_sale: true,
      sale_price: sale_price.to_f,
      original_price: product.price,
      price: sale_price.to_f
    )

    # Добавляем товар в категорию акций, если его там еще нет
    if sale_category && !product.categories.include?(sale_category)
      product.categories << sale_category
    end

    discount = ((1 - sale_price.to_f / product.original_price) * 100).round(1)
    bot.api.send_message(
      chat_id: message.chat.id,
      text: "✅ Товар \"#{product.name}\" добавлен в акцию:\nОбычная цена: #{product.original_price} MDL\nАкционная цена: #{sale_price} MDL\nСкидка: #{discount}%"
    )
  end

  def remove_sale(bot, message, product_id)
    product = Product.find(product_id)
    sale_category = Category.find_by(name: '🏷️ Акции')
    
    product.update(
      is_sale: false,
      sale_price: nil,
      price: product.original_price,
      original_price: nil
    )

    # Удаляем товар из категории акций
    if sale_category
      product.categories.delete(sale_category)
    end

    bot.api.send_message(
      chat_id: message.chat.id,
      text: "✅ Товар \"#{product.name}\" удален из акции\nЦена восстановлена: #{product.price} MDL"
    )
  end

  def list_sale_products(bot, message)
    products = Product.where(is_sale: true)
    
    if products.empty?
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Сейчас нет товаров по акции."
      )
      return
    end

    text = "Товары по акции:\n\n"
    products.each do |product|
      discount = ((1 - product.sale_price / product.original_price) * 100).round(1)
      text += "ID: #{product.id} | #{product.name}\n" \
              "#{product.original_price} MDL ➡️ #{product.sale_price} MDL (-#{discount}%)\n\n"
    end

    bot.api.send_message(
      chat_id: message.chat.id,
      text: text
    )
  end
end 