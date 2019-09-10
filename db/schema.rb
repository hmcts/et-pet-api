# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_14_115312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "building"
    t.string "street"
    t.string "locality"
    t.string "county"
    t.string "string"
    t.string "post_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country"
  end

  create_table "admin_permissions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_role_permissions", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "permission_id"
    t.index ["permission_id"], name: "index_admin_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_admin_role_permissions_on_role_id"
  end

  create_table "admin_roles", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "is_admin", default: false
    t.string "permission_names", array: true
  end

  create_table "admin_user_roles", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_admin_user_roles_on_role_id"
    t.index ["user_id"], name: "index_admin_user_roles_on_user_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "permission_names", array: true
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "name"
    t.string "department"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_admin_users_on_username", unique: true
  end

  create_table "claim_claimants", force: :cascade do |t|
    t.bigint "claim_id"
    t.bigint "claimant_id"
    t.index ["claim_id"], name: "index_claim_claimants_on_claim_id"
    t.index ["claimant_id"], name: "index_claim_claimants_on_claimant_id"
  end

  create_table "claim_representatives", force: :cascade do |t|
    t.bigint "claim_id"
    t.bigint "representative_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_claim_representatives_on_claim_id"
    t.index ["representative_id"], name: "index_claim_representatives_on_representative_id"
  end

  create_table "claim_respondents", force: :cascade do |t|
    t.bigint "claim_id"
    t.bigint "respondent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_claim_respondents_on_claim_id"
    t.index ["respondent_id"], name: "index_claim_respondents_on_respondent_id"
  end

  create_table "claim_uploaded_files", force: :cascade do |t|
    t.bigint "claim_id"
    t.bigint "uploaded_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_claim_uploaded_files_on_claim_id"
    t.index ["uploaded_file_id"], name: "index_claim_uploaded_files_on_uploaded_file_id"
  end

  create_table "claimants", force: :cascade do |t|
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.bigint "address_id"
    t.string "address_telephone_number"
    t.string "mobile_number"
    t.string "email_address"
    t.string "contact_preference"
    t.string "gender"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fax_number"
    t.text "special_needs"
    t.index ["address_id"], name: "index_claimants_on_address_id"
  end

  create_table "claims", force: :cascade do |t|
    t.string "reference"
    t.string "submission_reference"
    t.integer "claimant_count", default: 0, null: false
    t.string "submission_channel"
    t.string "case_type"
    t.integer "jurisdiction"
    t.integer "office_code"
    t.datetime "date_of_receipt"
    t.boolean "administrator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "primary_claimant_id", null: false
    t.string "other_known_claimant_names"
    t.string "discrimination_claims", default: [], null: false, array: true
    t.string "pay_claims", default: [], null: false, array: true
    t.string "desired_outcomes", default: [], null: false, array: true
    t.text "other_claim_details"
    t.text "claim_details"
    t.string "other_outcome"
    t.boolean "send_claim_to_whistleblowing_entity"
    t.text "miscellaneous_information"
    t.jsonb "employment_details", default: {}, null: false
    t.boolean "is_unfair_dismissal"
    t.bigint "primary_respondent_id"
    t.bigint "primary_representative_id"
    t.string "pdf_template_reference", null: false
    t.index ["primary_claimant_id"], name: "index_claims_on_primary_claimant_id"
    t.index ["primary_representative_id"], name: "index_claims_on_primary_representative_id"
    t.index ["primary_respondent_id"], name: "index_claims_on_primary_respondent_id"
  end

  create_table "commands", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "request_body", null: false
    t.jsonb "request_headers", null: false
    t.text "response_body", null: false
    t.jsonb "response_headers"
    t.integer "response_status"
    t.string "root_object_type"
    t.bigint "root_object_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_commands_on_id", unique: true
    t.index ["root_object_type", "root_object_id"], name: "index_commands_on_root_object_type_and_root_object_id"
  end

  create_table "diversity_responses", force: :cascade do |t|
    t.string "claim_type"
    t.string "sex"
    t.string "sexual_identity"
    t.string "age_group"
    t.string "ethnicity"
    t.string "ethnicity_subgroup"
    t.string "disability"
    t.string "caring_responsibility"
    t.string "gender"
    t.string "gender_at_birth"
    t.string "pregnancy"
    t.string "relationship"
    t.string "religion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "et_acas_api_download_logs", force: :cascade do |t|
    t.string "user_id"
    t.string "certificate_number"
    t.string "method_of_issue"
    t.string "message"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exported_files", force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "external_system_id", null: false
    t.index ["external_system_id"], name: "index_exported_files_on_external_system_id"
  end

  create_table "exports", force: :cascade do |t|
    t.bigint "resource_id"
    t.bigint "pdf_file_id"
    t.boolean "in_progress"
    t.string "messages", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_type"
    t.bigint "external_system_id", null: false
    t.index ["external_system_id"], name: "index_exports_on_external_system_id"
    t.index ["resource_id"], name: "index_exports_on_resource_id"
  end

  create_table "external_system_configurations", force: :cascade do |t|
    t.bigint "external_system_id", null: false
    t.string "key", null: false
    t.string "value", null: false
    t.boolean "can_read", default: true, null: false
    t.boolean "can_write", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_system_id"], name: "index_external_system_configurations_on_external_system_id"
  end

  create_table "external_systems", force: :cascade do |t|
    t.string "name", null: false
    t.string "reference", null: false
    t.integer "office_codes", default: [], array: true
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "export_queue"
    t.boolean "export", default: false
    t.index ["reference"], name: "index_external_systems_on_reference", unique: true
  end

  create_table "office_post_codes", force: :cascade do |t|
    t.string "postcode"
    t.bigint "office_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_office_post_codes_on_office_id"
    t.index ["postcode"], name: "index_office_post_codes_on_postcode", unique: true
  end

  create_table "offices", force: :cascade do |t|
    t.integer "code"
    t.string "name"
    t.boolean "is_default"
    t.string "address"
    t.string "telephone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pre_allocated_file_keys", force: :cascade do |t|
    t.string "key"
    t.string "allocated_to_type"
    t.bigint "allocated_to_id"
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allocated_to_type", "allocated_to_id"], name: "index_pre_allocated_file_keys_to_allocated_id_and_type"
  end

  create_table "representatives", force: :cascade do |t|
    t.string "name"
    t.string "organisation_name"
    t.bigint "address_id"
    t.string "address_telephone_number"
    t.string "mobile_number"
    t.string "email_address"
    t.string "representative_type"
    t.string "dx_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.string "contact_preference"
    t.string "fax_number"
    t.index ["address_id"], name: "index_representatives_on_address_id"
  end

  create_table "respondents", force: :cascade do |t|
    t.string "name"
    t.bigint "address_id"
    t.string "work_address_telephone_number"
    t.string "address_telephone_number"
    t.string "acas_number"
    t.bigint "work_address_id"
    t.string "alt_phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact"
    t.string "dx_number"
    t.string "contact_preference"
    t.string "email_address"
    t.string "fax_number"
    t.integer "organisation_employ_gb"
    t.boolean "organisation_more_than_one_site"
    t.integer "employment_at_site_number"
    t.boolean "disability"
    t.string "disability_information"
    t.string "acas_certificate_number"
    t.string "acas_exemption_code"
    t.index ["address_id"], name: "index_respondents_on_address_id"
    t.index ["work_address_id"], name: "index_respondents_on_work_address_id"
  end

  create_table "response_uploaded_files", force: :cascade do |t|
    t.bigint "response_id"
    t.bigint "uploaded_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_id"], name: "index_response_uploaded_files_on_response_id"
    t.index ["uploaded_file_id"], name: "index_response_uploaded_files_on_uploaded_file_id"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "respondent_id"
    t.bigint "representative_id"
    t.datetime "date_of_receipt"
    t.string "reference"
    t.string "case_number"
    t.string "claimants_name"
    t.boolean "agree_with_early_conciliation_details"
    t.string "disagree_conciliation_reason"
    t.boolean "agree_with_employment_dates"
    t.date "employment_start"
    t.date "employment_end"
    t.string "disagree_employment"
    t.boolean "continued_employment"
    t.boolean "agree_with_claimants_description_of_job_or_title"
    t.string "disagree_claimants_job_or_title"
    t.boolean "agree_with_claimants_hours"
    t.decimal "queried_hours", precision: 5, scale: 2
    t.boolean "agree_with_earnings_details"
    t.decimal "queried_pay_before_tax", precision: 8, scale: 2
    t.string "queried_pay_before_tax_period"
    t.decimal "queried_take_home_pay", precision: 8, scale: 2
    t.string "queried_take_home_pay_period"
    t.boolean "agree_with_claimant_notice"
    t.string "disagree_claimant_notice_reason"
    t.boolean "agree_with_claimant_pension_benefits"
    t.string "disagree_claimant_pension_benefits_reason"
    t.boolean "defend_claim"
    t.string "defend_claim_facts"
    t.boolean "make_employer_contract_claim"
    t.string "claim_information"
    t.string "email_receipt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pdf_template_reference", null: false
    t.string "email_template_reference", null: false
    t.index ["representative_id"], name: "index_responses_on_representative_id"
    t.index ["respondent_id"], name: "index_responses_on_respondent_id"
  end

  create_table "unique_references", force: :cascade do |t|
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.string "filename"
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "import_file_url"
    t.string "import_from_key"
  end

  add_foreign_key "claim_claimants", "claimants"
  add_foreign_key "claim_claimants", "claims"
  add_foreign_key "claim_representatives", "claims"
  add_foreign_key "claim_representatives", "representatives"
  add_foreign_key "claim_respondents", "claims"
  add_foreign_key "claim_respondents", "respondents"
  add_foreign_key "claim_uploaded_files", "claims"
  add_foreign_key "claim_uploaded_files", "uploaded_files"
  add_foreign_key "claimants", "addresses"
  add_foreign_key "exported_files", "external_systems"
  add_foreign_key "exports", "external_systems"
  add_foreign_key "office_post_codes", "offices"
  add_foreign_key "representatives", "addresses"
  add_foreign_key "respondents", "addresses"
  add_foreign_key "respondents", "addresses", column: "work_address_id"
  add_foreign_key "response_uploaded_files", "responses"
  add_foreign_key "response_uploaded_files", "uploaded_files"
end