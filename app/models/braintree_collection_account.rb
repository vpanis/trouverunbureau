class BraintreeCollectionAccount < ActiveRecord::Base
  # Relations
  has_one :venue

  attr_accessor :force_submit

  validates :first_name, :last_name, :email, :date_of_birth, :individual_street_address,
            :individual_locality, :individual_region, :individual_posta_code,
            :account_number_last4, :routing_number, presence: true, unless: :force_submit

  validate :legal_name_and_tax_id_presence, unless: :force_submit

  before_save :cut_sensible_data
  after_create :generate_merchant_account_id

  @append_random = Rails.configuration.payment.braintree.append_random_to_accounts_ids

  def braintree_merchant_account_json
    json = {}
    json[:individual] = account_individual_json
    json[:business] = account_business_json unless business_blank?
    json[:funding] = account_funding_json
    json
  end

  private

  def cut_sensible_data
    self.ssn_last4 = ssn_last4.last(4) if ssn_last4_changed?
    self.account_number_last4 = account_number_last4 % 1000 if account_number_last4_changed?
  end

  def generate_merchant_account_id
    return if merchant_account_id.present?
    update_attribute(merchant_account_id: "#{SecureRandom.hex(8) + '-' if @append_random}#{id}")
  end

  def legal_name_and_tax_id_presence
    return unless legal_name.blank? ^ tax_id.blank? # ^ XOR
    str = 'if one of legal name and tax id, is setted the other is required'
    errors.add(:legal_name_and_tax_id_presence, str)
  end

  def account_individual_json
    json = {
      first_name: first_name, last_name: last_name, email: email, phone: phone,
      date_of_birth: date_of_birth.to_s,
      address: {
        street_address: individual_street_address, locality: individual_locality,
        region: individual_region, postal_code: individual_postal_code
      }
    }
    json[:ssn] = ssn_last4 if ssn_last4_changed?
    json
  end

  def business_blank?
    legal_name.blank? && dba_name.blank? && tax_id.blank? && bussines_address_blank?
  end

  def bussines_address_blank?
    business_street_address.blank? && business_locality.blank? &&
      business_region.blank? && business_postal_code.blank?
  end

  def account_business_json
    {
      legal_name: legal_name, dba_name: dba_name, tax_id: tax_id,
      address: {
        street_address: business_street_address, locality: business_locality,
        region: business_region, postal_code: business_postal_code
      }
    }
  end

  def account_funding_json
    json = {
      descriptor: descriptor,
      destination: Braintree::MerchantAccount::FundingDestination::Bank,
      routing_number: routing_number
    }
    json[:account_number] = account_number_last4 if account_number_last4_changed?
    json
  end
end
