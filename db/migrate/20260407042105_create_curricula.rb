class CreateCurricula < ActiveRecord::Migration[8.1]
  def change
    # Rails generates "curriculas" — rename to canonical "curricula"
    create_table :curricula do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :organization_machine, null: false, foreign_key: true
      t.string :title, null: false
      t.string :role_level, null: false   # entry | experienced | lead
      t.string :status, null: false, default: "generating"  # generating | draft | published | archived
      t.jsonb :source_document_ids, default: []
      t.datetime :generated_at

      t.timestamps
    end

    add_index :curricula, [:organization_machine_id, :role_level, :status]
  end
end
