class MangopayCreditCard < ActiveRecord::Base
  belongs_to :mangopay_payment_account
end
