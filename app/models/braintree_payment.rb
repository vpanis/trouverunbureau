class BraintreePayment < ActiveRecord::Base
  has_one :booking, as: :payment
end
