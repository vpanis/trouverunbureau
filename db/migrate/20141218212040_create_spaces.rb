class CreateSpaces < ActiveRecord::Migration
  def change
    create_table :spaces do |t|
      t.string :s_type
      t.string :name
      t.integer :capacity
      t.integer :quantity
      t.text :description
      t.belongs_to :venue, index: true

      t.timestamps
    end
  end
end
