class CreateCurriculumModules < ActiveRecord::Migration[8.1]
  def change
    create_table :curriculum_modules do |t|
      t.references :curriculum, null: false, foreign_key: {to_table: :curricula}
      t.string :title, null: false
      t.integer :position, null: false
      t.string :module_type, null: false  # content | quiz
      t.integer :estimated_minutes
      t.jsonb :content, default: {}       # markdown body or quiz questions array
      t.string :review_status, default: "unreviewed"  # unreviewed | reviewed | needs_attention

      t.timestamps
    end

    add_index :curriculum_modules, [:curriculum_id, :position], unique: true
  end
end
