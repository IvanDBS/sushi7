require 'nokogiri'
require 'httparty'
require_relative 'models'

class MenuScraperLight
  BASE_URL = 'https://ohmysushi.md'

  def self.scrape_menu
    puts "Начинаем парсинг меню (легкий режим)..."
    
    begin
      # Создаем основные категории, если они не существуют
      categories = {
        sets: Category.find_or_create_by!(name: '🍱 Сеты', url_name: 'seturi'),
        sushi: Category.find_or_create_by!(name: '🍣 Суши', url_name: 'sushi'),
        maki: Category.find_or_create_by!(name: '🍙 Маки-Нигири-Гункан', url_name: 'maki-nigiri-guncan'),
        poke: Category.find_or_create_by!(name: '🥗 Поке Боул', url_name: 'poke-bowl'),
        tempura: Category.find_or_create_by!(name: '🍤 Темпура', url_name: 'tempura'),
        vulcan: Category.find_or_create_by!(name: '🌋 Вулкан', url_name: 'vulcan'),
        wok: Category.find_or_create_by!(name: '🥢 Вок', url_name: 'wok'),
        soups: Category.find_or_create_by!(name: '🥣 Супы', url_name: 'supe'),
        drinks: Category.find_or_create_by!(name: '🥤 Напитки', url_name: 'bauturi'),
        desserts: Category.find_or_create_by!(name: '🍰 Десерты', url_name: 'dessert-2'),
        sale: Category.find_or_create_by!(name: '🏷️ Акции', url_name: 'reduceri')
      }
      
      # Парсим каждую категорию
      categories.each do |key, category|
        scrape_category(category)
        sleep(1) # Добавляем паузу между запросами
      end
      
      puts "\nПарсинг завершен!"
      puts "Всего категорий: #{Category.count}"
      puts "Всего продуктов: #{Product.count}"
      
    rescue => e
      puts "❌ Ошибка при парсинге меню: #{e.message}"
      puts e.backtrace
    end
  end
  
  private
  
  def self.scrape_category(category)
    begin
      page = 1
      has_more_pages = true
      
      while has_more_pages
        url = if page == 1
          "#{BASE_URL}/product-category/#{category.url_name}/"
        else
          "#{BASE_URL}/product-category/#{category.url_name}/page/#{page}/"
        end
        
        puts "\nЗагрузка категории #{category.name} (страница #{page}) (#{url})"
        
        response = HTTParty.get(url,
          headers: {
            'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
          }
        )
        puts "  Код ответа: #{response.code}"
        
        return unless response.code == 200
        
        doc = Nokogiri::HTML(response.body)
        products = doc.css('.product-small:not(.product), .product:not(.product-small)')
        
        # If no products found on this page, stop pagination
        if products.empty?
          has_more_pages = false
          break
        end
        
        products.each do |product_element|
          begin
            name = product_element.css('.product-title, .woocommerce-loop-product__title').text.strip
            puts "  Обработка продукта: #{name}"
            
            # Проверяем, существует ли продукт с таким названием
            existing_product = Product.find_by(name: name)
            if existing_product
              puts "    ⏩ Пропускаем существующий продукт: #{name}"
              next
            end
            
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
                
                # Создаем новый продукт
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
                
                # Создаем новый продукт
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
        
        # Move to next page
        page += 1
        sleep(1) # Add pause between pages
      end
      
    rescue => e
      puts "❌ Ошибка при парсинге категории #{category.name}: #{e.message}"
      puts e.backtrace
    end
  end
end

# Запускаем парсер, если файл запущен напрямую
if __FILE__ == $0
  MenuScraperLight.scrape_menu
end