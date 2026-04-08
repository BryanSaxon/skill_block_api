class CreateTrainingProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :training_progresses do |t|
      t.references :training_assignment, null: false, foreign_key: true
      t.references :curriculum_module, null: false, foreign_key: {to_table: :curriculum_modules}
      t.string :status, null: false, default: "not_started"  # not_started | in_progress | completed
      t.jsonb :quiz_answers, default: {}
      t.datetime :completed_at

      t.timestamps
    end

    add_index :training_progresses,
      [:training_assignment_id, :curriculum_module_id],
      unique: true,
      name: "index_training_progresses_on_assignment_and_module"
  end
end
