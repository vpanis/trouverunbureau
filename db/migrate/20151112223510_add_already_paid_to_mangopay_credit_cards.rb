class AddAlreadyPaidToMangopayCreditCards < ActiveRecord::Migration
  def change
    add_column :mangopay_credit_cards, :already_paid, :boolean, default: false
    MangopayCreditCard.all.each do |mcc|
      mcc.update_attributes(already_paid: true);
    end
  end
end
