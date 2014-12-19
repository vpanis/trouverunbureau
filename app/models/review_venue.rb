class ReviewVenue < ActiveRecord::Base
  belongs_to :venue
  belongs_to :from_user, class_name: "User"
end
