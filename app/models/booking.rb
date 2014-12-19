class Booking < ActiveRecord::Base
  belongs_to :user
  belongs_to :space

  TYPES = [:hour, :day, :week, :month]
  STATES = [:pending_authorization, :pending_payment, :paid, :canceled, :denied]
end
