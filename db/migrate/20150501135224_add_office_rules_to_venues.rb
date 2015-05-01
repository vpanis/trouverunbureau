class AddOfficeRulesToVenues < ActiveRecord::Migration
  def change
    add_column :venues, :office_rules, :text
  end
end
