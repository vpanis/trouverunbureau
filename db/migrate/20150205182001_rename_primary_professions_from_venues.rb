class RenamePrimaryProfessionsFromVenues < ActiveRecord::Migration
  def change
    rename_column :venues, :primary_professions, :professions
  end
end
