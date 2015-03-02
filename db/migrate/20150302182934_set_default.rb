class SetDefault < ActiveRecord::Migration
  def change
    change_column :bookings, :owner_delete, :boolean, default: false
    change_column :bookings, :venue_owner_delete, :boolean, default: false
  end
end
