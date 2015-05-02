class AddNationalityAndCountryOfResidenceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nationality, :string
    add_column :users, :country_of_residence, :string

    User.update_all("nationality = 'FR', country_of_residence = 'FR', date_of_birth = '01-01-1988'")
  end
end
