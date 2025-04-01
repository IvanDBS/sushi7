require 'sinatra'
require_relative 'lib/webhook_server'
require_relative 'lib/bot'
require_relative 'lib/maib_client'

# Enable static file serving
use Rack::Static, 
  urls: ["/images"], 
  root: "public"

# Start the bot in a separate thread
Thread.new do
  bot = SushiBot.new
  bot.start
end

map '/webhook' do
  run lambda { |env|
    request = Rack::Request.new(env)
    
    if request.post?
      data = JSON.parse(request.body.read)
      signature = request.env['HTTP_X_MAIB_SIGNATURE']
      
      client = ENV['MAIB_TEST_MODE'] == 'true' ? MaibClientTest.new : MaibClient.new(
        ENV['MAIB_PROJECT_ID'],
        ENV['MAIB_PROJECT_SECRET'],
        ENV['MAIB_SIGNATURE_KEY']
      )
      
      if client.verify_signature(data, signature)
        order = Order.find_by(payment_id: data['result']['paymentId'])
        if order && data['result']['status'] == 'success'
          order.update(payment_status: 'paid')
          bot = SushiBot.new
          bot.complete_order(order)
        end
      end
    end
    
    [200, {'Content-Type' => 'text/plain'}, ['OK']]
  }
end

run Sinatra::Application 