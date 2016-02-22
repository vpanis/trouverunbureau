# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mangopay_collection_account do
    basic_info_only true
    expecting_mangopay_response false
    mangopay_persisted false
    legal_person_type 'PERSON'
    bank_type 'IBAN'
  end
end
