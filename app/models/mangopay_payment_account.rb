class MangopayPaymentAccount < ActiveRecord::Base
  has_many :mangopay_credit_cards
  belongs_to :buyer, polymorphic: true

  enum status: [:base, :processing, :accepted, :rejected]

  after_initialize :initialize_fields

  private

  def initialize_fields
    self.status ||= MangopayPaymentAccount.statuses[:base]
  end
end
