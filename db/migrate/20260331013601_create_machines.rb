class CreateMachines < ActiveRecord::Migration[8.1]
  def change
    create_table :machines do |t|
      t.references :manufacturer, null: false, foreign_key: true
      t.string :name, null: false
      t.string :model_number, null: false
      t.text :description

      t.timestamps
    end

    add_index :machines, [:manufacturer_id, :model_number], unique: true
  end
end
