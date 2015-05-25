class AddActiveToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :active, :boolean, default: false, null: false
    Space.joins(:photos).update_all(active: true)
  end
end
