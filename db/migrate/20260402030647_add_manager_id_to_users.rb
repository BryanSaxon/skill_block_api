class AddManagerIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :manager_id, :bigint, null: true
    add_index :users, :manager_id
    add_foreign_key :users, :users, column: :manager_id
  end
end
