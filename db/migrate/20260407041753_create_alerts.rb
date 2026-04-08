class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.references :organization_machine, null: false, foreign_key: true
      t.string :parameter_name, null: false
      t.decimal :triggered_value, precision: 10, scale: 4, null: false
      t.decimal :threshold_value, precision: 10, scale: 4, null: false
      t.string :severity, null: false           # warning | critical
      t.string :status, null: false             # active | acknowledged | resolved
      t.datetime :triggered_at, null: false
      t.datetime :resolved_at
      t.references :resolved_by, foreign_key: {to_table: :users}
      t.text :acknowledgment_note

      t.timestamps
    end

    add_index :alerts, [:organization_machine_id, :status]
    add_index :alerts, [:organization_machine_id, :triggered_at]
  end
end
