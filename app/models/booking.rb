class Booking < ActiveRecord::Base
	# Relations
	belongs_to :user

	belongs_to :space

	# Constants/Enums
	TYPES = [:hour, :day, :week, :month]

	STATES = [:pending_authorization, :pending_payment, :paid, 
  		:canceled, :denied, :already_taken]

  	# Callbacks
  	before_validation :default_state

  	# Validations	
  	validates :user, :space, :state, :b_type, :quantity, :from, presence: true

  	validates :quantity, numericality: { 
		only_integer: true,
		greater_than_or_equal_to: 1
	}

	validates :state, inclusion: { in: STATES.map(&:to_s) }

	validates :b_type, inclusion: { in: TYPES.map(&:to_s) }


	private
		def default_state
			self.state = :pending_authorization if state.nil?
		end

end
