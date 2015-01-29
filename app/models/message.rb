class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :organization
  belongs_to :user

  enum m_type: [:text, :pending_authorization, :pending_payment, :paid,
                :canceled, :denied, :already_taken]

  validates :m_type, presence: true
  validates :text, presence: true, if: proc { |e| e.m_type == 'text' }
  validates :user, presence: true, unless: proc { |e| e.m_type == 'pending_authorization' }

end
