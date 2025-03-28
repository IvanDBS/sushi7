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
      
      doc.css('.product, .type-product').each do |product_element|
        begin
          name = product_element.css('.woocommerce-loop-product__title, .product-title').text.strip
          puts "  Обработка продукта: #{name}"
          
          # Парсим цену
          price_element = product_element.css('.price').first
          price = if price_element
            # Сначала проверяем наличие акционной цены
            sale_price = price_element.css('ins .amount').text.strip
            if !sale_price.empty?
              # Если есть акционная цена, используем её
              sale_price.gsub(/[^\d.]/, '').to_f
            else
              # Если нет акционной цены, используем обычную цену
              regular_price = price_element.css('.amount').first&.text || price_element.text
              regular_price.gsub(/[^\d.]/, '').to_f
            end
          else
            0.0
          end
          
          # Проверяем, что цена выглядит разумной
          if price > 1000
            puts "    ⚠️ Подозрительно высокая цена (#{price}), проверьте вручную"
          end
          
          # Получаем изображение
          image = product_element.css('img').first
          image_url = image['src'] if image
          
          # Получаем ссылку на страницу продукта
          product_link = product_element.css('a').first
          
          description = ""
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
              description = product_doc.css('.woocommerce-product-details__short-description, .product-short-description, .product-description').text.strip
              description = description.gsub(/\s+/, ' ').strip
              
              # Если описание пустое, попробуем найти его в других местах
              if description.empty?
                description = product_doc.css('.product-short-description, .description').text.strip
                description = description.gsub(/\s+/, ' ').strip
              end
            end
          end
          
          # Если описание все еще пустое, используем название продукта
          description = name if description.empty?
          
          # Создаем продукт
          Product.create!(
            name: name,
            description: description,
            price: price,
            image_url: image_url,
            category: category
          )
          
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