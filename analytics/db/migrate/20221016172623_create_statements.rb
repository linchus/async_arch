class CreateStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :statements do |t|
      t.string :account_public_id
      t.string :description
      t.integer :credit, default: 0
      t.integer :debit, default: 0
      t.string :ref_type
      t.string :ref_public_id

      t.timestamps
    end
  end
end
