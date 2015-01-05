class RenameVenueWorkersToOrganizationWorkers < ActiveRecord::Migration
	def change
		rename_table :venue_workers, :organization_users
		remove_reference :organization_users, :venue
		add_reference :organization_users, :organization
	end
end
