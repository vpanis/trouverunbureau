class DropCountryTable < ActiveRecord::Migration
  def up
    add_column :venues, :country_code, :string

    Venue.all.each do |venue|
      venue.update_attributes(country_code: country_name_to_country_code(venue.country_id))
    end

    remove_column :venues, :country_id

    drop_table :countries
  end

  def country_name_to_country_code(country_id)
    sql = "SELECT name FROM countries WHERE countries.id=#{country_id}"
    country_name = ActiveRecord::Base.connection.select_all(sql).first["name"]
    country_name = 'Sweden' if country_name == 'Sweeden'
    Country.find_country_by_name(country_name).alpha2
  end
end
