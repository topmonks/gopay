#!/usr/bin/env ruby

require 'securerandom'
require 'json'
require 'rack'

$gopay_storage = {}

class HelloWorld
  def call(env)
    path = env['PATH_INFO']
    method = env['REQUEST_METHOD']
    redirect_url = ENV['REDIRECT_URL']

    query = Rack::QueryParser.make_default(100000, 2).parse_query(env.fetch('QUERY_STRING', ''))

    case [path, method]
    when ['/', 'GET'] then
      [ 200,
        {'Content-Type' => 'text/html'},
        [$gopay_storage.to_s]
      ]
    when ['/api/oauth2/token', 'POST'] then
      [ 200,
        {'Content-Type' => 'application/json'},
        ["{\"access_token\":\"123\"}"]
      ]
    when [(/\/api\/payments\/payment\/\d*$/ === path) && path, 'GET'] then
      id = path.split('/').last
      gopay_id = $gopay_storage[id]

      state = $gopay_storage

      [ 200,
        {'Content-Type' => 'application/json'},
        ["{\"state\":\"PAID\"}"]
      ]
    when [(/\/api\/payments\/payment\/\d*\/fail/ === path) && path, 'GET'] then
      id = path.split('/')[-2]
      gopay_id = $gopay_storage[id]
      require 'pry'; binding.pry

      redirect_link = "http://localhost:3000/ticket_bundles/update_payment?#{Rack::Utils.build_query({ id: gopay_id })}"
      [ 301,
        {'Content-Type' => 'application/json', 'Location' => redirect_link },
        ["{\"state\":\"PAID\"}"]
      ]
    when ['/api/payments/payment', 'POST'] then
      url_id = SecureRandom.hex
      gopay_id = SecureRandom.rand.to_s[2..-1].to_i
      $gopay_storage[url_id] = gopay_id

      gateway_url = "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}/pay?id=#{url_id}"

      body = { "amount"=>2500,
               "currency"=>"CZK",
               "order_number"=>"ON-1039178271-1578044769725",
               "id"=>gopay_id,
               "state"=>"CREATED",
               "gw_url"=>gateway_url }
      [ 200,
        {'Content-Type' => 'application/json'},
        [body.to_json]
      ]
    when ['/pay', 'GET'] then
      gopay_id = $gopay_storage[query['id']]

      href = "http://localhost:3000/ticket_bundles/update_payment?#{Rack::Utils.build_query({ id: gopay_id })}"
      pay_link = "<a href='#{href}'>zaplatit</a>"

      payment_fail_link = "<a href='/api/payments/payment/#{gopay_id}/fail'>pokazit platbu</a>"

      [
        200,
        {'Content-Type' => 'text/html'},
        ["#{pay_link}</br>#{payment_fail_link}"]
      ]


    else
      unknown_endpoint(env)
    end
  end

  private

  def unknown_endpoint(env)
    path = env['PATH_INFO']

    [
      400,
      {'Content-Type' => 'text/html'},
      ["Unknown endpoint called #{path}</br>#{env}"]
    ]
  end
end

Rack::Handler::WEBrick.run HelloWorld.new
