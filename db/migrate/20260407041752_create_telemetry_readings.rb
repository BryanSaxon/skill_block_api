class CreateTelemetryReadings < ActiveRecord::Migration[8.1]
  def change
    create_table :telemetry_readings do |t|
      t.references :organization_machine, null: false, foreign_key: true
      t.string :parameter_name, null: false
      t.decimal :value, precision: 10, scale: 4, null: false
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :telemetry_readings,
              [:organization_machine_id, :parameter_name, :recorded_at],
              name: "index_telemetry_on_machine_param_time"
  end
end
