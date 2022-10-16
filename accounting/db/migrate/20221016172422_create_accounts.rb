class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.integer :user_id
      t.string :public_id
      t.string :label
      t.integer :cached_balance

      t.timestamps
    end
  end
end
