class AddAigClaimMadeToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :aig_claim_made, :boolean, default: false
  end
end
