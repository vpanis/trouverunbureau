namespace :braintree do
  desc 'Creates the Merchant Accounts for the venues in the seed'
  task merchant_accounts_for_seed: :environment do
    @master_account = Rails.configuration.payment.braintree.merchant_account_id
    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'the_place_ayacucho@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'The Place Ayacucho',
        dba_name: 'The Place Ayacucho',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-1'
    )
    puts 'MerchantAccount 0000000000000000-1:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'the_best_place1@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'The Best Place Buenos Aires',
        dba_name: 'The Best Place Buenos Aires',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-2'
    )
    puts 'MerchantAccount 0000000000000000-2:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'the_best_place2@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'The Best Place Madrid',
        dba_name: 'The Best Place Madrid',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-3'
    )
    puts 'MerchantAccount 0000000000000000-3:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'desklirium@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'Desklirium',
        dba_name: 'Desklirium',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-4'
    )
    puts 'MerchantAccount 0000000000000000-4:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'My Place',
        dba_name: 'My Place',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-5'
    )
    puts 'MerchantAccount 0000000000000000-5:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'the_other_desk@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'The Other Desk',
        dba_name: 'The Other Desk',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-6'
    )
    puts 'MerchantAccount 0000000000000000-6:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'the_other_desk2@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'The Other Desk 2',
        dba_name: 'The Other Desk 2',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-7'
    )
    puts 'MerchantAccount 0000000000000000-7:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue2@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'My Place 2',
        dba_name: 'My Place 2',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-8'
    )
    puts 'MerchantAccount 0000000000000000-8:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue_bohn@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'Bohn My Place',
        dba_name: 'Bohn My Place',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-9'
    )
    puts 'MerchantAccount 0000000000000000-9:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue_oslo@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'My Place Oslo',
        dba_name: 'My Place Oslo',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-10'
    )
    puts 'MerchantAccount 0000000000000000-10:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue_estambul@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'My Place Estambul',
        dba_name: 'My Place Estambul',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-11'
    )
    puts 'MerchantAccount 0000000000000000-11:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue_moscu@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'Moscu My Place',
        dba_name: 'Moscu My Place',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-12'
    )
    puts 'MerchantAccount 0000000000000000-12:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?

    result = Braintree::MerchantAccount.create(
      individual: {
        first_name: Braintree::Test::MerchantAccount::Approve,
        last_name: 'Doe',
        email: 'my_venue_kabul@example.com',
        phone: '5553334444',
        date_of_birth: '1981-11-19',
        ssn: '456-45-4567',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      business: {
        legal_name: 'My Place Kabul',
        dba_name: 'My Place Kabul',
        tax_id: '98-7654321',
        address: {
          street_address: '111 Main St',
          locality: 'Chicago',
          region: 'IL',
          postal_code: '60622'
        }
      },
      funding: {
        destination: Braintree::MerchantAccount::FundingDestination::Bank,
        account_number: '1123581321',
        routing_number: '071101307'
      },
      tos_accepted: true,
      master_merchant_account_id: @master_account,
      id: '0000000000000000-13'
    )
    puts 'MerchantAccount 0000000000000000-13:'
    puts 'Created' if result.success?
    puts "Error: #{result.message}" unless result.success?
  end
end
