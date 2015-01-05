class Venue < ActiveRecord::Base
	# Relations
	belongs_to :owner, polymorphic: true
	
	has_many :spaces, dependent: :destroy

	has_many :day_hours, class_name: "VenueHour", dependent: :destroy

	has_many :photos, class_name: "VenuePhoto", dependent: :destroy

  	# Uploaders
  	mount_uploader :logo, LogoUploader

  	# Constants/Enums
	TYPES = [:startup_office, :studio, :corporate_office, :bussines_center, :hotel]

	SPACE_UNIT_TYPES = [:square_mts, :square_foots]

	AMENITY_TYPES = [:wifi, :cafe_restaurant, :catering_available, 
		:coffee_tea_filtered_water, :lockers, :mail_service, :meeting_rooms,
		:pets_allowed, :phone_booth_room, :shared_kitchen, 
		:wheelchair_accessible]

	# Callbacks
	before_validation :default_rating_values, unless: :created_at
  	before_destroy :erase_logo

  	# Validations
  	validates :town, :street, :postal_code, :email, :latitude, :longitude, 
  		:name, :description, :currency, :v_type, :vat_tax_rate, :owner,
  		:rating, :quantity_reviews, :reviews_sum, presence: true

	validates :email, format: { 
		with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 
		on: :create 
	}

	validates :latitude, numericality: { 
		greater_than_or_equal_to: -90,
		less_than_or_equal_to: 90
	}

	validates :longitude, numericality: {
		greater_than_or_equal_to: -180,
		less_than_or_equal_to: 180
	}

	validates :space, :vat_tax_rate, numericality: { 
		greater_than_or_equal_to: 0 
	}

	validates :floors, :rooms, :desks, :quantity_reviews, :reviews_sum, numericality: { 
		only_integer: true,
		greater_than_or_equal_to: 0 
	}

	validates :v_type, inclusion: {
		in: TYPES.map(&:to_s)
	}

	validates :space_unit, inclusion: {
		in: SPACE_UNIT_TYPES.map(&:to_s)
	}

	validates :day_hours, length: {
		maximum: 7
	}

	validates :rating, numericality: {
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: 5
	}

	validate :each_amenity_inclusion

	private
		def default_rating_values
			self.quantity_reviews ||= 0
			self.reviews_sum ||= 0
			self.rating ||= 0
		end
	
	  	def erase_logo
	  		self.remove_logo!
	  	end

	  	def each_amenity_inclusion
			if (invalid_amenities = (amenities - AMENITY_TYPES.map(&:to_s)))
				invalid_amenities.each do |amenity|
					errors.add(:amenity_list, amenity + " is not a valid amenity")
				end
			end
	  	end
end
