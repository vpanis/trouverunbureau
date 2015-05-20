class CreateMangopayCollectionAccounts < ActiveRecord::Migration
  def change
    create_table :mangopay_collection_accounts do |t|
      t.boolean :active, default: false
      t.string :status
      t.text :error_message

      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :nationality
      t.string :country_of_residence
      t.date :date_of_birth
      t.string :address
      t.string :legal_person_type

      t.string :business_name
      t.string :business_email

      t.string :bank_type

      t.string :iban_last_4
      t.string :bic

      t.string :account_number_last_4
      t.string :sort_code

      t.string :bank_name
      t.string :institution_number
      t.string :branch_code

      t.string :bank_country

      t.string :mangopay_user_id
      t.string :wallet_id
      t.string :bank_account_id
      t.boolean :mangopay_persisted
      t.boolean :expecting_mangopay_response

      t.timestamps
    end
  end
end
