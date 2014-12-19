class ReviewUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :from_user, class_name: "User"
end
