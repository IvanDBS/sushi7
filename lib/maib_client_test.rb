require 'json'
require 'base64'
require 'openssl'

class MaibClientTest
  BASE_URL = 'https://test-api.maibmerchants.md/v1'
  
  def initialize(project_id = 'test_project', project_secret = 'test_secret', signature_key = 'test_key')
    @project_id = project_id
    @project_secret = project_secret
    @signature_key = signature_key
  end

  def create_payment(order)
    # Генерируем тестовые данные
    payment_id = "test_payment_#{Time.now.to_i}"
    redirect_url = "https://test-payment.example.com/#{payment_id}"
    
    # Сохраняем тестовые данные в заказ
    order.update(
      payment_id: payment_id,
      payment_status: 'pending'
    )
    
    {
      'paymentId' => payment_id,
      'redirectUrl' => redirect_url,
      'status' => 'success'
    }
  end

  def verify_signature(params, signature)
    # В тестовом режиме всегда возвращаем true
    true
  end

  def simulate_payment_callback(order, status = 'success')
    # Генерируем тестовые данные для callback
    callback_data = {
      'result' => {
        'paymentId' => order.payment_id,
        'status' => status,
        'maibStatus' => status == 'success' ? 'APPROVED' : 'DECLINED',
        'rrn' => "test_rrn_#{Time.now.to_i}",
        'approval' => "test_approval_#{Time.now.to_i}",
        'card' => '**** **** **** 1234'
      }
    }
    
    # Генерируем тестовую подпись
    signature = Base64.strict_encode64(
      OpenSSL::Digest::SHA256.digest("test_signature")
    )
    
    [callback_data, signature]
  end

  private

  def generate_token
    'test_token'
  end
end 