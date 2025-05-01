require 'httparty'

class RunpayService
  include HTTParty
  base_uri Runpay.configuration.api_url

  def initialize
    @options = {
      headers: {
        'Authorization' => "Bearer #{Runpay.configuration.api_key}",
        'Content-Type' => 'application/json'
      }
    }
  end

  def create_payment(amount, currency, order_id, description)
    body = {
      amount: amount,
      currency: currency,
      order_id: order_id,
      description: description,
      success_url: "#{ENV['APP_URL']}/payment/success",
      cancel_url: "#{ENV['APP_URL']}/payment/cancel"
    }

    response = self.class.post('/payments', @options.merge(body: body.to_json))
    handle_response(response)
  end

  def get_payment_status(payment_id)
    response = self.class.get("/payments/#{payment_id}", @options)
    handle_response(response)
  end

  private

  def handle_response(response)
    if response.success?
      response.parsed_response
    else
      raise "RunPay API Error: #{response.code} - #{response.body}"
    end
  end
end 