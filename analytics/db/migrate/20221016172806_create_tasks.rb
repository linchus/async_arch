class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :public_id
      t.string :title
      t.string :state

      t.timestamps
    end
  end
end
