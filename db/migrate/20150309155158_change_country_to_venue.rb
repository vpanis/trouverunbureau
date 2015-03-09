class ChangeCountryToVenue < ActiveRecord::Migration
  def change
    add_reference :venues, :country, index: true
  end
end
