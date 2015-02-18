class AddLanguagesSpokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :languages_spoken, :text, array: true, default: []
  end
end
