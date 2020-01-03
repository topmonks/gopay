module Gopay
  module Mixins
    module Controller
      def update
        GopayPayment.find_by!(gopay_id: params[:id]).update_gopay_status!

        render json: { ok: true }
      end
    end

    module Model
      extend ActiveSupport::Concern

      included do
        belongs_to :target,
          polymorphic: true,
          inverse_of: :gopay_payments

        validates :gopay_id,
          presence: true
        validates :amount,
          presence: true
        validates :currency,
          presence: true
        validates :state,
          presence: true

        scope :paid, -> { where(state: 'PAID') }
        scope :unpaid, -> { where.not(state: 'PAID') }
        scope :ordered, -> { order(:created_at) }
      end

      class_methods do
        def create_gopay!(target, return_url, notification_url)
          raise('No return url') if return_url.blank?

          payment = target.gopay_payments.build
          response = Gopay::Service.create_payment!(payment.data(return_url, notification_url))
          puts response
          payment.amount = response['amount']
          payment.currency = response['currency']
          payment.order_number = response['order_number']
          payment.gopay_id = response['id']
          payment.state = response['state']
          payment.gateway_url = response['gw_url']
          payment.save!
          payment
        end
      end

      def paid?
        state == 'PAID'
      end

      def data(return_url, notification_url)
        { amount: target.gopay_price.to_i,
          currency: target.gopay_currency,
          items: target.gopay_items,
          callback: { return_url: return_url, notification_url: notification_url } }
      end

      def update_gopay_status!
        response = Gopay::Service.payment(gopay_id)
        status = response['state']
        self.class.transaction do
          update!(state: status)
          yield status if block_given?
        end
      end

    end
  end
end
