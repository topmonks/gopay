# frozen_string_literal: true

class GopayCreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :gopay_payments do |t|
      t.belongs_to :target, polymorphic: true, index: true, null: false
      t.integer :amount, null: false
      t.string :currency, null: false
      t.string :order_number
      t.string :gopay_id, null: false
      t.string :state, null: false
      t.string :gateway_url

      t.index(:gateway_url, unique: true)
      t.index(:gopay_id, unique: true)

      t.timestamps null: false
    end
  end
end
