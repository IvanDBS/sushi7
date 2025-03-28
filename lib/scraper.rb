require 'nokogiri'
require 'httparty'
require_relative 'models'

class MenuScraper
  BASE_URL = 'https://ohmysushi.md'

  def self.scrape_menu
    response = HTTParty.get(BASE_URL)
    doc = Nokogiri::HTML(response.body)

    # Здесь будет реализована логика парсинга меню
    # В зависимости от структуры сайта, нужно будет настроить
    # соответствующие селекторы для извлечения данных

    doc.css('.menu-category').each do |category_element|
      category_name = category_element.css('.category-name').text.strip
      category = Category.find_or_create_by(name: category_name)

      category_element.css('.menu-item').each do |item_element|
        product_data = {
          name: item_element.css('.item-name').text.strip,
          description: item_element.css('.item-description').text.strip,
          price: item_element.css('.item-price').text.gsub(/[^\d.]/, '').to_f,
          image_url: item_element.css('.item-image').attr('src')&.value,
          category: category
        }

        Product.find_or_create_by(name: product_data[:name]) do |product|
          product.assign_attributes(product_data)
        end
      end
    end
  end
end 