class AddMTypeToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :m_type, :integer
  end
end
