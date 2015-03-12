# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :braintree_collection_account do
    force_submit true
    expecting_braintree_response false
    braintree_persisted false

    trait :with_valid_data do
      first_name 'Jane'
      last_name 'Doe'
      email 'jane@14ladders.com'
      phone '5553334444'
      date_of_birth '1981-11-19'
      individual_street_address '111 Main St'
      individual_locality 'Chicago'
      individual_region 'IL'
      individual_postal_code '60622'
      legal_name 'Jane\'s Ladders'
      dba_name 'Jane\'s Ladders'
      tax_id '98-7654321'
      business_street_address '111 Main St'
      business_locality 'Chicago'
      business_region 'IL'
      business_postal_code '60622'
      descriptor 'Blue Ladders'
      account_number '1123581321'
      routing_number '071101307'
      force_submit false
    end

    trait :with_invalid_routing_number do
      routing_number '71101307'
    end
  end
end
