class CreateAuthProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :auth_providers do |t|
      t.integer :account_id
      t.string :uid
      t.string :provider
      t.string :username
      t.jsonb :user_info

      t.timestamps
    end
  end
end
