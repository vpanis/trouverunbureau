class BraintreePayment < ActiveRecord::Base
  has_one :booking
end
