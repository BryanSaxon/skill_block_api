class CreateMachineParameters < ActiveRecord::Migration[8.1]
  def change
    create_table :machine_parameters do |t|
      t.references :organization_machine, null: false, foreign_key: true
      t.string :name, null: false
      t.string :unit, null: false
      t.decimal :normal_min, precision: 10, scale: 4
      t.decimal :normal_max, precision: 10, scale: 4
      t.decimal :warning_threshold, precision: 10, scale: 4
      t.decimal :critical_threshold, precision: 10, scale: 4
      t.integer :display_order, null: false, default: 0

      t.timestamps
    end

    add_index :machine_parameters, [:organization_machine_id, :name], unique: true
  end
end
