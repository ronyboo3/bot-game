class RenameColumnOfUserStatusToPartner < ActiveRecord::Migration
  def change
    rename_column :users, :status, :partner
  end
end
