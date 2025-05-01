require 'sinatra'
require_relative 'lib/models'
require_relative 'lib/runpay_client'
require_relative 'lib/runpay_webhook'

# Enable static file serving
use Rack::Static, 
  urls: ["/images"], 
  root: "public"

run RunPayWebhook 