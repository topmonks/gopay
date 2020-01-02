# frozen_string_literal: true

require 'rest_client'

module Gopay
  class Error < StandardError
    def self.handle(response)
      new("#{response.code}: #{response.body}")
    end
  end

  class Service
    class << self
      attr_accessor :client_id, :client_secret, :goid, :gate_url

      def configure
        yield self
      end

      def create_payment!(data)
        default_target = { target: { type: 'ACCOUNT', goid: goid } }
        request :post, '/api/payments/payment', params: data.merge(default_target).to_json
      end

      def payment(id)
        request :get, "/api/payments/payment/#{id}"
      end

      private

      def request(method, path, params: nil)
        response = case method.to_sym
                   when :post
                     RestClient.post(gate_url + path, params, headers(path))
                   when :get
                     RestClient.get(gate_url + path, headers(path))
                   end

        raise Gopay::Error.handle(response) unless response.code == 200

        JSON.parse(response.body)
      rescue RestClient::Exception => e
        raise(e.response)
      end

      def headers(path)
        { 'Accept' => 'application/json',
          'Content-Type' => content_type(path),
          'Authorization' => "Bearer #{token(token_scope(path))}" }
      end

      def token_scope(path)
        payment?(path) ? 'payment-create' : 'payment-all'
      end

      def content_type(path)
        payment?(path) ? 'application/json' : 'application/x-www-form-urlencoded'
      end

      # payment-create - for new payment
      # payment-all - for testing state etc
      def token(scope = 'payment-create')
        response = RestClient.post("#{gate_url}/api/oauth2/token", { grant_type: 'client_credentials', scope: scope },
                                   'Accept' => 'application/json',
                                   'Content-Type' => 'application/x-www-form-urlencoded',
                                   'Authorization' => "Basic #{Base64.encode64(client_id + ':' + client_secret)}")
        JSON.parse(response.body)['access_token']
      end

      def payment?(path)
        path == '/api/payments/payment'
      end
    end
  end
end
