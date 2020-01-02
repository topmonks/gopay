# frozen_string_literal: true

Gopay::Service.configure do |config|
  config.goid = ENV['GOPAY_ID']
  config.client_id = ENV['GOPAY_CLIENT_ID']
  config.client_secret = ENV['GOPAY_CLIENT_SECRET']
  config.gate_url = if Rails.env.production?
                      'https://gate.gopay.cz'
                    else
                      'https://gw.sandbox.gopay.com'
                    end
end
