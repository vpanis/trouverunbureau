class ChangeEnumsToIntegers < ActiveRecord::Migration
  def change
    change_column :bookings, :b_type, 'integer USING CAST(b_type AS integer)'
    change_column :bookings, :state, 'integer USING CAST(state AS integer)'
    change_column :spaces, :s_type, 'integer USING CAST(s_type AS integer)'
    change_column :venues, :v_type, 'integer USING CAST(v_type AS integer)'
    change_column :venues, :space_unit, 'integer USING CAST(space_unit AS integer)'
    change_column :organization_users, :role, 'integer USING CAST(role AS integer)'
  end
end
