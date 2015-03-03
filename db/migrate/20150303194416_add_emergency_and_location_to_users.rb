class AddEmergencyAndLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :location, :text
    add_column :users, :emergency_name, :text
    add_column :users, :emergency_email, :text
    add_column :users, :emergency_phone, :text
    add_column :users, :emergency_relationship, :text
  end
end
