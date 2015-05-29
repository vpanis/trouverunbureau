class ChangeBookingReferenceFromReceipts < ActiveRecord::Migration
  def change
    remove_reference :receipts, :booking
    add_reference :receipts, :payment, polymorphic: true, index: true
  end
end
