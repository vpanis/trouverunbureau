class CreateUsersFavorites < ActiveRecord::Migration
  def change
    create_table :users_favorites do |t|
      t.belongs_to :user, index: true
      t.belongs_to :space, index: true
      t.date :since

      t.timestamps
    end
  end
end
