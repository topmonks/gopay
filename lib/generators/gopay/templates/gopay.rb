# frozen_string_literal: true

Gopay::Service.configure do |config|
  config.goid = Figaro.env.GOPAY_ID
  config.client_id = Figaro.env.GOPAY_CLIENT_ID
  config.client_secret = Figaro.env.GOPAY_CLIENT_SECRET
  config.gate_url = if Rails.env.production?
                      'https://gate.gopay.cz'
                    else
                      'https://gw.sandbox.gopay.com'
                    end
end
