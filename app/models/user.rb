class User < ActiveRecord::Base
	has_many :venue_workers
	has_many :venues, through: :venue_workers
end
