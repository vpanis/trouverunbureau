class AddMangopayCreditCardToMangopayPayments < ActiveRecord::Migration
  def change
    add_reference :mangopay_payments, :mangopay_credit_card, index: true
  end
end
