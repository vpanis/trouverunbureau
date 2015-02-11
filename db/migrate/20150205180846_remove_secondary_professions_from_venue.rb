class RemoveSecondaryProfessionsFromVenue < ActiveRecord::Migration
  def change
    remove_column :venues, :secondary_professions
  end
end
