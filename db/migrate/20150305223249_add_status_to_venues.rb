class AddStatusToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :status, :integer
  end
end
