class MangopayCreditCard < ActiveRecord::Base
  belongs_to :mangopay_payment_account

  scope :activated, -> { where(status: MangopayCreditCard.statuses[:created]) }
  scope :not_activated, -> { where('status != ?', MangopayCreditCard.statuses[:created]) }

  enum status: [:registering, :needs_validation, :failed, :created]
  CURRENCIES = %w(EUR USD GBP PLN CHF NOK SEK DKK)
  EURO_COUNTRIES_3166_ALPHA_3 = %w(AND AUT BEL DNK FIN FRA DEU GIB IRL ITA LIE LUX MCO NLD NOR PRT
                                   SMR ESP SWE CHE GBR VAT)

  validates :currency, inclusion: { in: CURRENCIES }
  validates :mangopay_payment_account, :registration_expiration_date, :status,
            presence: true

end
