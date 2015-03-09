class ChangeCountryToVenue < ActiveRecord::Migration
  def change
    remove_column :venues, :country, :string
    add_reference :venues, :country, index: true
  end
end
