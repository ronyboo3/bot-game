class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :image_name
      t.string :confirm_url
      t.string :for_sendding_url

      t.timestamps null: false
    end
  end
end
