class AddColumnLevelToUser < ActiveRecord::Migration
  def change
    add_column :users, :level, :string, :after => :name
  end
end
