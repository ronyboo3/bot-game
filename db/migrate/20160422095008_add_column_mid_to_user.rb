class AddColumnMidToUser < ActiveRecord::Migration
  def change
    add_column :users, :mid, :string
  end
end
