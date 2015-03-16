class BraintreeCollectionAccount < ActiveRecord::Base
  # Relations
  has_one :venue

  attr_accessor :force_submit, :ssn, :account_number

  validates :first_name, :last_name, :email, :date_of_birth, :individual_street_address,
            :individual_locality, :individual_region, :individual_postal_code,
            :routing_number, presence: true, unless: :force_submit

  validate :account_number_or_last_4_presence, unless: :force_submit

  validate :legal_name_and_tax_id_presence, unless: :force_submit

  after_create :generate_merchant_account_id, unless: :merchant_account_id

  def braintree_merchant_account_json
    json = {}
    json[:individual] = account_individual_json
    json[:business] = account_business_json
    json[:funding] = account_funding_json
    json
  end

  def active?
    status == Braintree::MerchantAccount::Status::Active
  end

  def pending?
    status == Braintree::MerchantAccount::Status::Pending
  end

  def suspended?
    status == Braintree::MerchantAccount::Status::Suspended
  end

  def error?
    status == 'error'
  end

  private

  def generate_merchant_account_id
    return if merchant_account_id.present?
    update_attributes(merchant_account_id:
      "#{SecureRandom.hex(8) + '-' if
      Rails.configuration.payment.braintree.append_random_to_accounts_ids}#{id}")
  end

  def legal_name_and_tax_id_presence
    return unless legal_name.blank? ^ tax_id.blank? # ^ XOR
    str = 'if one of legal name and tax id, is setted the other is required'
    errors.add(:legal_name_and_tax_id_presence, str)
  end

  def account_number_or_last_4_presence
    return unless account_number.blank? && account_number_last_4.blank?
    errors.add(:account_number, :not_present)
  end

  def account_individual_json
    json = {}
    %w(first_name last_name email phone date_of_birth).each do |field|
      json[field.to_sym] = send(field).to_s
    end
    json[:ssn] = ssn if ssn.present?
    json[:address] = address_json('individual')
    json
  end

  def address_json(type)
    json = {}
    json[:street_address] = send("#{type}_street_address")
    json[:locality] = send("#{type}_locality")
    json[:region] = send("#{type}_region")
    json[:postal_code] = send("#{type}_postal_code")
    json
  end

  def account_business_json
    json = {}
    %w(legal_name dba_name tax_id).each do |field|
      json[field.to_sym] = send(field).to_s
    end
    json[:address] = address_json('business')
    json.delete(:address) if json[:address].empty?
    json
  end

  def account_funding_json
    json = {}
    json[:descriptor] = descriptor
    json[:destination] = Braintree::MerchantAccount::FundingDestination::Bank unless
      braintree_persisted
    json[:routing_number] = routing_number
    json[:account_number] = account_number if account_number.present?
    json
  end
end
