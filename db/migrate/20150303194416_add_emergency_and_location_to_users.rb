class AddEmergencyAndLocationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :location, :string
    add_column :users, :emergency_name, :string
    add_column :users, :emergency_email, :string
    add_column :users, :emergency_phone, :string
    add_column :users, :emergency_relationship, :string
  end
end
