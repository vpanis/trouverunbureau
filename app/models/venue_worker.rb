class VenueWorker < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue

  ROLES = [:owner, :admin]
end
