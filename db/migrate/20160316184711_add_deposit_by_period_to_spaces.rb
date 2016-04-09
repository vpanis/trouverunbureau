class AddDepositByPeriodToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :hour_deposit, :integer
    add_column :spaces, :day_deposit, :integer
    add_column :spaces, :week_deposit, :integer
    add_column :spaces, :month_deposit, :integer
    add_column :spaces, :month_to_month_deposit, :integer

    Space.where("deposit is NOT NULL and deposit > ?", 0).each do |space|
      deposit = space.deposit

      space.hour_deposit            = deposit if space.hour_price.present?
      space.day_deposit             = deposit if space.day_price.present?
      space.week_deposit            = deposit if space.week_price.present?
      space.month_deposit           = deposit if space.month_price.present?
      space.month_to_month_deposit  = deposit if space.month_to_month_price.present?

      space.save!
    end

  end
end
