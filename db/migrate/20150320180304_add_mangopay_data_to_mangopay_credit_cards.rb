class AddMangopayDataToMangopayCreditCards < ActiveRecord::Migration
  def change
    add_column :mangopay_credit_cards, :status, :integer
    add_column :mangopay_credit_cards, :currency, :string
    add_column :mangopay_credit_cards, :card_registration_url, :string
    add_column :mangopay_credit_cards, :pre_registration_data, :string
    add_column :mangopay_credit_cards, :registration_access_key, :string
    add_column :mangopay_credit_cards, :registration_id, :string
    add_column :mangopay_credit_cards, :registration_expiration_date, :datetime
    add_column :mangopay_credit_cards, :error_message, :text
  end
end
