class CreateTrainingAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :training_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :curriculum, null: false, foreign_key: { to_table: :curricula }
      t.references :organization_machine, null: false, foreign_key: true
      t.string :status, null: false, default: "not_started"  # not_started | in_progress | completed
      t.date :due_date
      t.references :assigned_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :training_assignments, [:user_id, :curriculum_id], unique: true
    add_index :training_assignments, [:user_id, :status]
  end
end
