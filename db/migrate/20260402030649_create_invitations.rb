class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.integer :role, null: false, default: 2
      t.bigint :organization_id, null: false
      t.bigint :invited_by_id, null: false
      t.datetime :accepted_at
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, :email
    add_index :invitations, :organization_id
    add_foreign_key :invitations, :organizations
    add_foreign_key :invitations, :users, column: :invited_by_id
  end
end
