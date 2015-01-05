class Organization < ActiveRecord::Base
	# Only for creation purpose
	attr_accessor :user, :user_id

	has_many :organization_users
	has_many :users, through: :organization_users
	has_many :venues, as: :owner
	has_many :bookings, as: :owner

	# Only for the creation stage, it needs a user
	validate :has_user, unless: :created_at 

	validates :name, :email, :phone, presence: true

	validates :email, format: { 
		with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 
		on: :create 
	}

	after_create :assign_user

	private
		def has_user
			if user.nil? && user_id.nil?
				errors.add(:user, "Needs to have a user/user_id value")
			else
				begin
					if !user.nil?
						User.find(user.id)
					elsif !user_id.nil? 
						User.find(user_id)
					end
				rescue
					errors.add(:user, "Invalid user/user_id value")
				end
			end
		end

		def assign_user
			if !user.nil?
				organization_users.create(user_id: user.id, role: "owner")
			elsif !user_id.nil?
				organization_users.create(user_id: user_id, role: "owner")
			end
		end
end
