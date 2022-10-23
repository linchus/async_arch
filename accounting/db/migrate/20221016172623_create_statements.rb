class CreateStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :statements do |t|
      t.integer :account_id
      t.string :description
      t.integer :credit
      t.integer :debit
      t.references :ref, null: false, polymorphic: true

      t.timestamps
    end
  end
end
