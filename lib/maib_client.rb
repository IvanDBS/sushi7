require 'http'
require 'json'
require 'base64'
require 'openssl'

class MaibClient
  BASE_URL = 'https://api.maibmerchants.md/v1'
  
  def initialize(project_id, project_secret, signature_key)
    @project_id = project_id
    @project_secret = project_secret
    @signature_key = signature_key
  end

  def create_payment(order)
    token = generate_token
    
    response = HTTP.auth("Bearer #{token}")
      .post("#{BASE_URL}/pay", json: {
        amount: order.total_amount,
        currency: 'MDL',
        orderId: order.id.to_s,
        description: "Заказ ##{order.id} в Oh! My Sushi",
        callbackUrl: ENV['MAIB_CALLBACK_URL'],
        returnUrl: "https://t.me/#{ENV['BOT_USERNAME']}"
      })

    JSON.parse(response.body.to_s)
  end

  def verify_signature(params, signature)
    return false unless params['result']

    data = params['result'].sort.map { |k, v| v.to_s }.join(':')
    data = "#{data}:#{@signature_key}"
    
    calculated = Base64.strict_encode64(
      OpenSSL::Digest::SHA256.digest(data)
    )
    
    calculated == signature
  end

  private

  def generate_token
    timestamp = Time.now.to_i
    nonce = SecureRandom.uuid
    
    signature = OpenSSL::HMAC.hexdigest(
      'SHA256',
      @project_secret,
      "#{@project_id}:#{timestamp}:#{nonce}"
    )

    response = HTTP.post("#{BASE_URL}/auth", json: {
      projectId: @project_id,
      timestamp: timestamp,
      nonce: nonce,
      signature: signature
    })

    JSON.parse(response.body.to_s)['token']
  end
end 