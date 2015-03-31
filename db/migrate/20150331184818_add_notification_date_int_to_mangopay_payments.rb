class AddNotificationDateIntToMangopayPayments < ActiveRecord::Migration
  def change
    add_column :mangopay_payments, :notification_date_int, :integer
  end
end
