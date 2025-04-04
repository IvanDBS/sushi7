require 'nokogiri'
require 'httparty'
require_relative 'models'

class MenuScraper
  BASE_URL = 'https://ohmysushi.md'

  def self.scrape_menu
    puts "Начинаем парсинг меню..."
    # Очищаем старые данные
    Product.delete_all
    Category.delete_all
    
    # Сбрасываем последовательность ID
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE products_id_seq RESTART WITH 1;")
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE categories_id_seq RESTART WITH 1;")
    
    begin
      # Создаем основные категории вручную
      categories = {
        sets: Category.create!(name: '🍱 Сеты', url_name: 'seturi'),
        sushi: Category.create!(name: '🍣 Суши', url_name: 'sushi'),
        maki: Category.create!(name: '🍙 Маки-Нигири-Гункан', url_name: 'maki-nigiri-guncan'),
        poke: Category.create!(name: '🥗 Поке Боул', url_name: 'poke-bowl'),
        tempura: Category.create!(name: '🍤 Темпура', url_name: 'tempura'),
        vulcan: Category.create!(name: '🌋 Вулкан', url_name: 'vulcan'),
        wok: Category.create!(name: '🥢 Вок', url_name: 'wok'),
        soups: Category.create!(name: '🥣 Супы', url_name: 'supe'),
        drinks: Category.create!(name: '🥤 Напитки', url_name: 'bauturi'),
        desserts: Category.create!(name: '🍰 Десерты', url_name: 'dessert-2'),
        sale: Category.create!(name: '🏷️ Акции', url_name: 'reduceri')
      }
      
      # Парсим каждую категорию
      categories.each do |key, category|
        scrape_category(category)
        sleep(1) # Добавляем паузу между запросами
      end
      
      puts "\nПарсинг завершен!"
      puts "Создано категорий: #{Category.count}"
      puts "Создано продуктов: #{Product.count}"
      
    rescue => e
      puts "❌ Ошибка при парсинге меню: #{e.message}"
      puts e.backtrace
    end
  end
  
  private
  
  def self.scrape_category(category)
    begin
      url = "#{BASE_URL}/product-category/#{category.url_name}/"
      puts "\nЗагрузка категории #{category.name} (#{url})"
      
      response = HTTParty.get(url,
        headers: {
          'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }
      )
      puts "  Код ответа: #{response.code}"
      
      return unless response.code == 200
      
      doc = Nokogiri::HTML(response.body)
      
      # Обновленные селекторы для новой структуры сайта
      doc.css('.product-small:not(.product), .product:not(.product-small)').each do |product_element|
        begin
          name = product_element.css('.product-title, .woocommerce-loop-product__title').text.strip
          puts "  Обработка продукта: #{name}"
          
          # Получаем изображение
          image = product_element.css('img').first
          image_url = image['src'] if image
          
          # Получаем ссылку на страницу продукта и описание
          description = ""
          product_link = product_element.css('a').first
          if product_link
            product_url = product_link['href']
            puts "    Загрузка страницы продукта: #{product_url}"
            product_response = HTTParty.get(product_url,
              headers: {
                'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
              }
            )
            if product_response.code == 200
              product_doc = Nokogiri::HTML(product_response.body)
              
              # Пробуем найти описание в разных местах, но берем только первое найденное
              description_element = product_doc.css('.woocommerce-product-details__short-description, .product-short-description, .product-description').first
              if description_element
                description = description_element.text.strip
              end
              
              # Если не нашли, пробуем альтернативные места
              if description.empty?
                description_element = product_doc.css('.product-short-description, .description').first
                if description_element
                  description = description_element.text.strip
                end
              end
              
              # Очищаем описание от лишних пробелов и переносов строк
              description = description.gsub(/\s+/, ' ').strip
              
              # Если описание все еще пустое, используем название продукта
              description = name if description.empty?
            end
          end
          
          # Парсим цену
          price_element = product_element.css('.price, .amount').first
          if price_element
            # Сначала проверяем наличие акционной цены
            sale_price_element = price_element.css('ins .amount').first
            regular_price_element = price_element.css('.amount').first
            
            if sale_price_element
              # Если есть акционная цена
              sale_price = sale_price_element.text.strip.gsub(/[^\d,]/, '').gsub(',', '.').to_f
              regular_price = regular_price_element.text.strip.gsub(/[^\d,]/, '').gsub(',', '.').to_f
              
              # Проверяем, существует ли продукт с таким названием
              product = Product.find_by(name: name)
              
              if product
                # Если продукт существует, обновляем его
                product.update!(
                  description: description,
                  price: sale_price,
                  image_url: image_url,
                  is_sale: true,
                  sale_price: sale_price,
                  original_price: regular_price
                )
              else
                # Если продукт не существует, создаем новый
                product = Product.create!(
                  name: name,
                  description: description,
                  price: sale_price,
                  image_url: image_url,
                  category: category,
                  is_sale: true,
                  sale_price: sale_price,
                  original_price: regular_price
                )
              end
              
              # Добавляем товар в категорию акций
              sale_category = Category.find_by(name: '🏷️ Акции')
              if sale_category
                product.categories << sale_category unless product.categories.include?(sale_category)
              end
              
              price = sale_price
            else
              # Если нет акционной цены
              regular_price = regular_price_element&.text || price_element.text
              regular_price = regular_price.gsub(/[^\d,]/, '').gsub(',', '.').to_f
              
              # Проверяем, существует ли продукт с таким названием
              product = Product.find_by(name: name)
              
              if product
                # Если продукт существует, обновляем его
                product.update!(
                  description: description,
                  price: regular_price,
                  image_url: image_url,
                  is_sale: false,
                  sale_price: regular_price,
                  original_price: regular_price
                )
              else
                # Если продукт не существует, создаем новый
                Product.create!(
                  name: name,
                  description: description,
                  price: regular_price,
                  image_url: image_url,
                  category: category,
                  is_sale: false,
                  sale_price: regular_price,
                  original_price: regular_price
                )
              end
              
              price = regular_price
            end
          else
            price = 0.0
          end
          
          # Проверяем, что цена выглядит разумной
          if price > 1000
            puts "    ⚠️ Подозрительно высокая цена (#{price}), проверьте вручную"
          end
          
          puts "    ✓ Цена: #{price} MDL"
          puts "    ✓ Описание: #{description[0..50]}..."
          
          sleep(0.5) # Добавляем небольшую паузу между продуктами
          
        rescue => e
          puts "    ❌ Ошибка при обработке продукта #{name}: #{e.message}"
          puts e.backtrace
        end
      end
      
    rescue => e
      puts "❌ Ошибка при парсинге категории #{category.name}: #{e.message}"
      puts e.backtrace
    end
  end
end

# Запускаем парсер, если файл запущен напрямую
if __FILE__ == $0
  MenuScraper.scrape_menu
end 