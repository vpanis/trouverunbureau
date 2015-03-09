class Country < ActiveRecord::Base
  has_many :venues
  validates :name, presence: true
end
