class MangopayCollectionAccount < ActiveRecord::Base
  has_one :venue, as: :collection_account

  attr_accessor :account_number, :iban, :basic_info_only, :update_user_only

  LEGAL_TYPES = %w(PERSON BUSINESS ORGANIZATION)
  BANK_TYPES = %w(IBAN GB CA OTHER)

  enum status: [:base, :processing, :accepted, :rejected, :error_updating]

  before_save :cut_important_data

  validates :legal_person_type, inclusion: { in: LEGAL_TYPES }, if: :user_valid?

  validates :bank_type, inclusion: { in: BANK_TYPES }, if: :bank_valid?

  # User Info
  validates :first_name, :last_name, :email, :nationality, :country_of_residence, :date_of_birth,
            :legal_person_type, :bank_type, presence: true, if: :user_valid?

  validates :nationality, :country_of_residence, inclusion: { in: User::SUPPORTED_NATIONALITIES },
                                                 if: :user_valid?

  # User Info (Only BUSINESS and ORGANIZATION)
  validates :business_name, :business_email,
            presence: true,
            if: proc { |mca| mca.user_valid? && !person? }

  # Bank Info
  validates :address, presence: true, if: :bank_valid?

  validates :bic, presence: true,
                  if: proc { |mca| mca.bank_valid? && bank_type.in?(%w(IBAN OTHER)) }

  validates :sort_code,
            presence: true,
            if: proc { |mca| mca.bank_valid? && mca.bank_type == 'GB' }
  validates :bank_name, :institution_number, :branch_code,
            presence: true,
            if: proc { |mca| mca.bank_valid? && mca.bank_type == 'CA' }
  validates :bank_country,
            presence: true,
            if: proc { |mca| mca.bank_valid? && mca.bank_type == 'OTHER' }

  validates :iban, presence: true, if: :iban_valid?
  validates :account_number, presence: true, if: :account_number_valid?

  def json_data_for_mangopay
    json = as_json(only: [
      :first_name, :last_name, :email, :nationality, :country_of_residence,
      :date_of_birth, :legal_person_type, :bank_type, :business_name, :business_email, :address,
      :bic, :sort_code, :bank_name, :institution_number, :branch_code, :bank_country
    ])
    json[:account_number] = account_number if account_number.present?
    json['bic'] = json['bic'].delete(' ') if json['bic']
    json[:iban] = iban if iban.present?
    json
  end

  def person?
    legal_person_type == 'PERSON'
  end

  def generic_account_last_4
    return iban_last_4 if bank_type == 'IBAN'
    account_number_last_4
  end

  protected

  def account_number_valid?
    bank_valid? && bank_type.in?(%w(GB CA OTHER)) && account_number_last_4.blank?
  end

  def iban_valid?
    bank_valid? && bank_type == 'IBAN' && iban_last_4.blank?
  end

  def bank_valid?
    !update_user_only.present? && !basic_info_only.present?
  end

  def user_valid?
    !basic_info_only.present?
  end

  private

  def cut_important_data
    self.account_number_last_4 = account_number.last(4) if account_number.present?
    self.iban_last_4 = iban.last(4) if iban.present?
  end
end
