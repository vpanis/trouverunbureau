FactoryGirl.define do
  factory :mangopay_payment_account do
    buyer { FactoryGirl.create(:user) }
    wallet_id 'MOCK_WALLET_ID'
    mangopay_user_id 'MOCK_USER_ID'
    status { MangopayPaymentAccount.statuses[:accepted] }
  end
end
