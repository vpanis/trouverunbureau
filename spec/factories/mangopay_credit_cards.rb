FactoryGirl.define do
  factory :mangopay_credit_card do
    mangopay_payment_account { FactoryGirl.create(:mangopay_payment_account) }
    currency 'EUR'
    status { MangopayCreditCard.statuses[:registering] }
    registration_expiration_date { Time.current.advance(hours: 6) }
  end
end
