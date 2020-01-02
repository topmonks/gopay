# frozen_string_literal: true

module Gopay
  class PaymentsController < ::ApplicationController
    def update
      Gopay::Payment.find_by!(gopay_id: params[:id]).update_gopay_status!

      render json: { ok: true }
    end
  end
end
