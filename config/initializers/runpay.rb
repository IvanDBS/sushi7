require 'dotenv/load'

module Runpay
  class Configuration
    attr_accessor :api_key, :api_url, :webhook_secret

    def initialize
      @api_key = ENV['RUNPAY_API_KEY']
      @api_url = ENV['RUNPAY_API_URL'] || 'https://api.runpay.com/v1'
      @webhook_secret = ENV['RUNPAY_WEBHOOK_SECRET']
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end
  end
end 