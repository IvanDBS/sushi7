require 'http'
require 'json'
require 'securerandom'
require 'logger'

class RunPayClient
  BASE_URL = 'https://ecom.runpay.md'
  API_VERSION = 'v2'

  def initialize
    @merchant_id = ENV['RUNPAY_MERCHANT_ID'] || '67cb8fe3-ec30-4e97-8e59-7f53389fcf37'
    @test_mode = ENV['RUNPAY_TEST_MODE'] == 'true'
    @token = ENV['RUNPAY_API_TOKEN'] || '74141657084fa83a003ae4150259f50bb5d32aaa8a0771e30a608cb53eaeb374e2bd52e5d27f7d4f20f755ded57b7234452e'
    setup_logger
  end

  def create_invoice(invoice:, amount:, paymentMethod:)
    request_data = {
      merchantId: @merchant_id,
      invoice: {
        description: invoice[:description],
        params: invoice[:params] || {}
      },
      amount: amount.is_a?(Hash) ? amount : {
        value: amount.to_f,
        currency: "MDL"
      },
      paymentMethod: paymentMethod,
      testMode: @test_mode
    }
    
    @logger.info("RunPay request to: #{BASE_URL}/api/#{API_VERSION}/invoices")
    @logger.info("RunPay request data: #{JSON.pretty_generate(request_data)}")
    
    headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Idempotency-Key' => SecureRandom.hex(4), # Required by API
      'Authorization' => "Bearer #{@token}"     # Always include token (required)
    }
    
    @logger.info("Request headers: #{headers.inspect}")
    
    response = HTTP
      .headers(headers)
      .post(
        "#{BASE_URL}/api/#{API_VERSION}/invoices",
        json: request_data
      )

    @logger.info("RunPay response status: #{response.status}")
    @logger.info("RunPay response body: #{response.body.to_s}")

    if response.status.success?
      data = JSON.parse(response.body.to_s)
      if data["url"]
        @logger.info("RunPay payment URL received: #{data["url"]}")
        {
          "status" => "success",
          "paymentId" => data["paymentId"],
          "url" => data["url"]
        }
      else
        @logger.error("RunPay response has no payment URL: #{data.inspect}")
        {
          "status" => "error",
          "code" => "invalid_response",
          "message" => "Response missing required URL field"
        }
      end
    else
      begin
        error_data = JSON.parse(response.body.to_s)
        @logger.error("RunPay error response: #{error_data.inspect}")
        {
          "status" => "error",
          "code" => error_data["code"] || "unknown_error",
          "message" => error_data["message"] || "Unknown error occurred",
          "errors" => error_data["errors"]
        }
      rescue JSON::ParserError
        @logger.error("Failed to parse RunPay error response: #{response.body.to_s}")
        {
          "status" => "error",
          "code" => "parse_error",
          "message" => "Failed to parse error response",
          "raw_response" => response.body.to_s
        }
      end
    end
  rescue => e
    @logger.error("RunPay exception: #{e.message}")
    @logger.error(e.backtrace.join("\n"))
    {
      "status" => "error",
      "code" => "client_error",
      "message" => e.message,
      "backtrace" => e.backtrace
    }
  end

  def get_payment_status(payment_id)
    headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Authorization' => "Bearer #{@token}" # Always include token (required)
    }

    @logger.info("Getting payment status for payment_id: #{payment_id}")
    response = HTTP
      .headers(headers)
      .timeout(10) # Добавляем таймаут в 10 секунд
      .get("#{BASE_URL}/api/#{API_VERSION}/payments/#{payment_id}")

    @logger.info("Payment status response: #{response.body.to_s}")

    if response.status.success?
      data = JSON.parse(response.body.to_s)
      {
        "status" => "success",
        "payment" => data
      }
    else
      begin
        error_data = JSON.parse(response.body.to_s)
        @logger.error("Error checking payment status: #{error_data.inspect}")
        {
          "status" => "error",
          "code" => error_data["code"] || "unknown_error",
          "message" => error_data["message"] || "Unknown error occurred"
        }
      rescue JSON::ParserError
        @logger.error("Failed to parse payment status response: #{response.body.to_s}")
        {
          "status" => "error",
          "code" => "parse_error",
          "message" => "Failed to parse error response"
        }
      end
    end
  rescue HTTP::TimeoutError => e
    @logger.error("Timeout checking payment status: #{e.message}")
    {
      "status" => "error",
      "code" => "timeout",
      "message" => "Request timed out"
    }
  rescue => e
    @logger.error("Error getting payment status: #{e.message}")
    @logger.error(e.backtrace.join("\n"))
    {
      "status" => "error",
      "code" => "client_error",
      "message" => e.message
    }
  end

  private

  def setup_logger
    @logger = Logger.new('log/runpay.log', 'daily')
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}] #{severity}: #{msg}\n"
    end
  end
end 