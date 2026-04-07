class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :organization_machine, foreign_key: true  # nullable — some docs are org-wide
      t.string :name, null: false
      t.string :document_type, null: false   # sop | manual | reference
      t.string :status, null: false, default: "processing"  # processing | ready | used | error
      t.integer :page_count

      t.timestamps
    end

    add_index :documents, [:organization_id, :status]
  end
end
