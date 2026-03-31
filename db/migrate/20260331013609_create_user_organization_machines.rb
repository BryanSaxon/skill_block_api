class CreateUserOrganizationMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :user_organization_machines do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization_machine, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_organization_machines, [:user_id, :organization_machine_id], unique: true
  end
end
