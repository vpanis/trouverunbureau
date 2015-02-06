class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :booking, index: true
      t.belongs_to :organization, index: true
      t.belongs_to :user, index: true
      t.text :text

      t.timestamps
    end
  end
end
