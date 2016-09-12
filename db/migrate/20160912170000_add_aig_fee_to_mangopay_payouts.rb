class AddAigFeeToMangopayPayouts < ActiveRecord::Migration
  def change
    add_column :mangopay_payouts, :aig_fee, :integer, default: 0
  end
end
