path = '/api/payments/payment/291202095541516'
method = 'GET'

case [path, method]
when [(/\/api\/payments\/payment\/\d*$/ === path) && path, 'GET'] then
  puts 'cool'
else
  p 'not cool'
end
