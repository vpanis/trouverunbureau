class Venue < ActiveRecord::Base
	belongs_to :owner, class_name: "User"

	TYPES = [:startup_office, :studio, :corporate_office, :bussines_center, :hotel]

	SPACE_UNIT_TYPES = [:square_mts, :square_foots]

	AMENITY_TYPES = [:wifi, :cafe_restaurant, :catering_available, 
		:coffee_tea_filtered_water, :lockers, :mail_service, :meeting_rooms,
		:pets_allowed, :phone_booth_room, :shared_kitchen, 
		:wheelchair_accessible]


end
