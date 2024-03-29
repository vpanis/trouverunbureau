class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end

    add_index :organizations, :email, unique: true
  end
end
