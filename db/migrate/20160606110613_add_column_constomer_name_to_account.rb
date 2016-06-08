class AddColumnConstomerNameToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :customer_name, :string, :after => :image_name
  end
end
