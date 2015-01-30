class ChangeOrganizationToRepresentedFromMessage < ActiveRecord::Migration
  def change
    remove_reference :messages, :organization
    add_reference :messages, :represented, polymorphic: true, index: true
  end
end
