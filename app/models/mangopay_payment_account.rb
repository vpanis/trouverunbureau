class MangopayPaymentAccount < ActiveRecord::Base
  has_many :mangopay_credit_cards
end
