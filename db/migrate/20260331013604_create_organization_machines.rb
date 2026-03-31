class CreateOrganizationMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_machines do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :machine, null: false, foreign_key: true
      t.string :vin, null: false
      t.string :nickname
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :organization_machines, [:organization_id, :vin], unique: true
  end
end
