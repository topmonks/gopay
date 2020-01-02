# Gopay

Gopay payments integration into Rails apps. Work in progress. Don't use unless you know what you do.

## Installation and usage

Add this line to your application's Gemfile:

```ruby
gem 'gopay', github: 'topmonkscom/gopay'
```

And then execute:

    $ bundle

Note that it's not yet released to Rubygems. Gem Gopay on Rubygems is something else

Then execute:

```
rails g gopay:install
rails db:migrate
```

This will create all the necessary files for Gopay models.

Then in model you wish to be payable with Gopay:

```
class Order
  has_many :gopay_payments, as: :target, dependent: :destroy

  def gopay_price
    order_items.sum(&:price) * 100
  end

  def gopay_items
    order_items.map { |item| { name: 'item.id', amount: item.price * 100 } }
  end

  def gopay_currency
    'CZK'
  end
end
```

Then in controller where you wish to prepare payment:

```
def create
 payment = GopayPayment.create_gopay!(@order, gopay_notification_url, gopay_notification_url)

 respond_to do |format|
   format.json { render json: { gw_url: payment.gw_url } }
 end
end

def update
  @payment = @order.gopay_payments.find_by!(gopay_id: params[:id])

  @payment.update_gopay_status! do |status| # Run in transaction
    @order.pay! if status == 'PAID' # or:
    @order.update!(state: status)
  end

  respond_to do |format|
    format.json { render json: { state: @payment.state } }
    format.html {}
  end
end
```

* In view:

```
button_tag 'Pay', class: 'btn btn-success btn-accept btn-lg',style: 'background-color: #009edb', id: 'payment-invoke-checkout'

<script type="text/javascript" src="<%= "#{Gopay::Service.gate_url}/gp-gw/js/embed.js" %>"></script>

<script type="text/javascript">
    $(document).ready(function () {
        $('#payment-invoke-checkout').on('click', function (event) {
            event.preventDefault();
            $.ajax({
                url: '<%= create_payment_url(@order) %>',
                type: 'POST',
                data: {}

            }).done(function (inlineCreateResult) {
                _gopay.checkout({gatewayUrl: inlineCreateResult.gw_url, inline: false}, function (checkoutResult) {
                    // Only for inline: true option:
                    $.ajax({
                        url: '<%= update_payments_path(@order) %>/' + checkoutResult.id,
                        type: 'PUT',
                        data: {}

                    }).done(function (inlineGetStateResult) {
                        alert('Success');
                    });
                });

            }).error(function (data) {
                alert('error' + data);
            });
        });
    });
</script>
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gopay.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
