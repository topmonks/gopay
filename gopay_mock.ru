require 'securerandom'
require 'json'
require 'rack/query_parser'

$storage = {}

class HelloWorld
  def call(env)
    # require 'pry'; binding.pry


    path = env['PATH_INFO']
    method = env['REQUEST_METHOD']
    query = Rack::QueryParser.make_default(100000, 2).parse_query(env.fetch('QUERY_STRING', ''))

    case [path, method]
    when ['/api/oauth2/token', 'POST'] then
      [ 200,
        {'Content-Type' => 'application/json'},
        ["{\"access_token\":\"123\"}"]
      ]
    when [(/\/api\/payments\/payment\/\d*$/ === path) && path, 'GET'] then
      [ 200,
        {'Content-Type' => 'application/json'},
        ["{\"state\":\"PAID\"}"]
      ]
    when ['/api/payments/payment', 'POST'] then
      url_id = SecureRandom.hex
      gopay_id = SecureRandom.rand.to_s[2..-1].to_i
      $storage[url_id] = gopay_id

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
      gopay_id = $storage[query['id']]

      href = "http://localhost:3000/ticket_bundles/update_payment?#{Rack::Utils.build_query({ id: gopay_id })}"

      # require 'pry'; binding.pry
      # # 

      [
        200,
        {'Content-Type' => 'text/html'},
        ["<a href='#{href}'>zaplatit</a>"]
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

run HelloWorld.new
