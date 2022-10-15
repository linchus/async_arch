class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :public_id
      t.string :state
      t.references :assigned_to, null: false
      t.references :created_by, null: false
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
