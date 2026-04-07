# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_07_042527) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.text "acknowledgment_note"
    t.datetime "created_at", null: false
    t.bigint "organization_machine_id", null: false
    t.string "parameter_name", null: false
    t.datetime "resolved_at"
    t.bigint "resolved_by_id"
    t.string "severity", null: false
    t.string "status", null: false
    t.decimal "threshold_value", precision: 10, scale: 4, null: false
    t.datetime "triggered_at", null: false
    t.decimal "triggered_value", precision: 10, scale: 4, null: false
    t.datetime "updated_at", null: false
    t.index ["organization_machine_id", "status"], name: "index_alerts_on_organization_machine_id_and_status"
    t.index ["organization_machine_id", "triggered_at"], name: "index_alerts_on_organization_machine_id_and_triggered_at"
    t.index ["organization_machine_id"], name: "index_alerts_on_organization_machine_id"
    t.index ["resolved_by_id"], name: "index_alerts_on_resolved_by_id"
  end

  create_table "curricula", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.bigint "organization_id", null: false
    t.bigint "organization_machine_id", null: false
    t.string "role_level", null: false
    t.jsonb "source_document_ids", default: []
    t.string "status", default: "generating", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_curricula_on_organization_id"
    t.index ["organization_machine_id", "role_level", "status"], name: "idx_on_organization_machine_id_role_level_status_bf9fb58aff"
    t.index ["organization_machine_id"], name: "index_curricula_on_organization_machine_id"
  end

  create_table "curriculum_modules", force: :cascade do |t|
    t.jsonb "content", default: {}
    t.datetime "created_at", null: false
    t.bigint "curriculum_id", null: false
    t.integer "estimated_minutes"
    t.string "module_type", null: false
    t.integer "position", null: false
    t.string "review_status", default: "unreviewed"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["curriculum_id", "position"], name: "index_curriculum_modules_on_curriculum_id_and_position", unique: true
    t.index ["curriculum_id"], name: "index_curriculum_modules_on_curriculum_id"
  end

  create_table "document_chunks", force: :cascade do |t|
    t.integer "chunk_index", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "document_id", null: false
    t.vector "embedding", limit: 1536
    t.datetime "updated_at", null: false
    t.index ["document_id", "chunk_index"], name: "index_document_chunks_on_document_id_and_chunk_index", unique: true
    t.index ["document_id"], name: "index_document_chunks_on_document_id"
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document_type", null: false
    t.string "name", null: false
    t.bigint "organization_id", null: false
    t.bigint "organization_machine_id"
    t.integer "page_count"
    t.string "status", default: "processing", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "status"], name: "index_documents_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_documents_on_organization_id"
    t.index ["organization_machine_id"], name: "index_documents_on_organization_machine_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.bigint "invited_by_id", null: false
    t.bigint "organization_id", null: false
    t.integer "role", default: 2, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_invitations_on_email"
    t.index ["organization_id"], name: "index_invitations_on_organization_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "machine_parameters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "critical_threshold", precision: 10, scale: 4
    t.integer "display_order", default: 0, null: false
    t.string "name", null: false
    t.decimal "normal_max", precision: 10, scale: 4
    t.decimal "normal_min", precision: 10, scale: 4
    t.bigint "organization_machine_id", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
    t.decimal "warning_threshold", precision: 10, scale: 4
    t.index ["organization_machine_id", "name"], name: "index_machine_parameters_on_organization_machine_id_and_name", unique: true
    t.index ["organization_machine_id"], name: "index_machine_parameters_on_organization_machine_id"
  end

  create_table "machines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "manufacturer_id", null: false
    t.string "model_number", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["manufacturer_id", "model_number"], name: "index_machines_on_manufacturer_id_and_model_number", unique: true
    t.index ["manufacturer_id"], name: "index_machines_on_manufacturer_id"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_manufacturers_on_name", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "message", null: false
    t.jsonb "navigation_target", default: {}
    t.string "notification_type", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organization_machines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "machine_id", null: false
    t.string "nickname"
    t.bigint "organization_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "vin", null: false
    t.index ["machine_id"], name: "index_organization_machines_on_machine_id"
    t.index ["organization_id", "vin"], name: "index_organization_machines_on_organization_id_and_vin", unique: true
    t.index ["organization_id"], name: "index_organization_machines_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "org_type", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_organizations_on_name", unique: true
    t.index ["org_type"], name: "index_organizations_on_org_type"
    t.index ["org_type"], name: "index_organizations_one_admin", unique: true, where: "(org_type = 0)"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "telemetry_readings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_machine_id", null: false
    t.string "parameter_name", null: false
    t.datetime "recorded_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10, scale: 4, null: false
    t.index ["organization_machine_id", "parameter_name", "recorded_at"], name: "index_telemetry_on_machine_param_time"
    t.index ["organization_machine_id"], name: "index_telemetry_readings_on_organization_machine_id"
  end

  create_table "training_assignments", force: :cascade do |t|
    t.bigint "assigned_by_id", null: false
    t.datetime "created_at", null: false
    t.bigint "curriculum_id", null: false
    t.date "due_date"
    t.bigint "organization_machine_id", null: false
    t.string "status", default: "not_started", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["assigned_by_id"], name: "index_training_assignments_on_assigned_by_id"
    t.index ["curriculum_id"], name: "index_training_assignments_on_curriculum_id"
    t.index ["organization_machine_id"], name: "index_training_assignments_on_organization_machine_id"
    t.index ["user_id", "curriculum_id"], name: "index_training_assignments_on_user_id_and_curriculum_id", unique: true
    t.index ["user_id", "status"], name: "index_training_assignments_on_user_id_and_status"
    t.index ["user_id"], name: "index_training_assignments_on_user_id"
  end

  create_table "training_progresses", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "curriculum_module_id", null: false
    t.jsonb "quiz_answers", default: {}
    t.string "status", default: "not_started", null: false
    t.bigint "training_assignment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["curriculum_module_id"], name: "index_training_progresses_on_curriculum_module_id"
    t.index ["training_assignment_id", "curriculum_module_id"], name: "index_training_progresses_on_assignment_and_module", unique: true
    t.index ["training_assignment_id"], name: "index_training_progresses_on_training_assignment_id"
  end

  create_table "user_organization_machines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "organization_machine_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organization_machine_id"], name: "index_user_organization_machines_on_organization_machine_id"
    t.index ["user_id", "organization_machine_id"], name: "idx_on_user_id_organization_machine_id_2358481fcb", unique: true
    t.index ["user_id"], name: "index_user_organization_machines_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.bigint "manager_id"
    t.bigint "organization_id", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "organization_machines"
  add_foreign_key "alerts", "users", column: "resolved_by_id"
  add_foreign_key "curricula", "organization_machines"
  add_foreign_key "curricula", "organizations"
  add_foreign_key "curriculum_modules", "curricula", column: "curriculum_id"
  add_foreign_key "document_chunks", "documents"
  add_foreign_key "documents", "organization_machines"
  add_foreign_key "documents", "organizations"
  add_foreign_key "invitations", "organizations"
  add_foreign_key "invitations", "users", column: "invited_by_id"
  add_foreign_key "machine_parameters", "organization_machines"
  add_foreign_key "machines", "manufacturers"
  add_foreign_key "notifications", "users"
  add_foreign_key "organization_machines", "machines"
  add_foreign_key "organization_machines", "organizations"
  add_foreign_key "sessions", "users"
  add_foreign_key "telemetry_readings", "organization_machines"
  add_foreign_key "training_assignments", "curricula", column: "curriculum_id"
  add_foreign_key "training_assignments", "organization_machines"
  add_foreign_key "training_assignments", "users"
  add_foreign_key "training_assignments", "users", column: "assigned_by_id"
  add_foreign_key "training_progresses", "curriculum_modules"
  add_foreign_key "training_progresses", "training_assignments"
  add_foreign_key "user_organization_machines", "organization_machines"
  add_foreign_key "user_organization_machines", "users"
  add_foreign_key "users", "organizations"
  add_foreign_key "users", "users", column: "manager_id"
end
