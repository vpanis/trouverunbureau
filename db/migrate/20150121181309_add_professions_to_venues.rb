class AddProfessionsToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :primary_professions, :text, array: true, default: []
    add_column :venues, :secondary_professions, :text, array: true, default: []
  end
end
