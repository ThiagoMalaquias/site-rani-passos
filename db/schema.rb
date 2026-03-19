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

ActiveRecord::Schema.define(version: 2026_03_14_200320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "access_groups", force: :cascade do |t|
    t.string "name"
    t.text "access"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
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
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "advertisements", force: :cascade do |t|
    t.string "title"
    t.string "status", default: "inactive"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "link"
    t.text "image"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "alternatives", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "title"
    t.boolean "correct", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_alternatives_on_question_id"
  end

  create_table "assessment_subjects", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assessment_id"], name: "index_assessment_subjects_on_assessment_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "video"
    t.string "instructions"
    t.text "file"
    t.text "file_answer_comments"
    t.integer "clicks", default: 0
    t.bigint "tag_id"
    t.boolean "segmented", default: false
    t.string "slug"
    t.index ["tag_id"], name: "index_assessments_on_tag_id"
  end

  create_table "banners", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.string "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "open_url"
    t.string "url"
    t.string "image"
    t.string "image_mobile"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences", default: 0
    t.index ["company_id"], name: "index_banners_on_company_id"
  end

  create_table "blog_courses", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blog_id"], name: "index_blog_courses_on_blog_id"
    t.index ["course_id"], name: "index_blog_courses_on_course_id"
  end

  create_table "blogs", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.string "status"
    t.text "image"
    t.text "content"
    t.bigint "manager_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "favorite", default: 0
    t.integer "clicks", default: 0
    t.index ["manager_id"], name: "index_blogs_on_manager_id"
  end

  create_table "campaign_users", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.string "name"
    t.string "email"
    t.boolean "opened", default: false
    t.boolean "clicked", default: false
    t.string "message_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_campaign_users_on_campaign_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "segment"
    t.string "status", default: "open"
    t.datetime "start_date"
    t.string "subject"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "image"
    t.string "button_name"
    t.string "button_link"
    t.string "button_color"
  end

  create_table "capsules", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "name"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences", default: 0
    t.bigint "matter_id"
    t.index ["course_id"], name: "index_capsules_on_course_id"
    t.index ["matter_id"], name: "index_capsules_on_matter_id"
  end

  create_table "cart_discounts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "inactive"
    t.index ["company_id"], name: "index_cart_discounts_on_company_id"
  end

  create_table "cashback_interests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_cashback_interests_on_course_id"
    t.index ["user_id"], name: "index_cashback_interests_on_user_id"
  end

  create_table "cashback_movements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "payment_id"
    t.integer "amount_cents", null: false
    t.string "kind", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_cashback_movements_on_payment_id"
    t.index ["user_id"], name: "index_cashback_movements_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.string "slug"
    t.bigint "sub_category_id"
    t.text "description"
    t.string "photo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences", default: 0
    t.string "status_disclosure", default: "active"
    t.index ["company_id"], name: "index_categories_on_company_id"
  end

  create_table "chat_gpt_messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "question"
    t.text "answer"
    t.integer "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_chat_gpt_messages_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "corporate_name"
    t.string "cnpj"
    t.string "adress"
    t.string "number"
    t.string "complement"
    t.string "neighborhood"
    t.string "city"
    t.string "phone"
    t.string "email"
    t.text "description"
    t.text "acknowledgment"
    t.text "message_email"
    t.text "institucional"
    t.text "mission"
    t.text "vision"
    t.text "values"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "message_email_course_free"
    t.text "reset_password_instructions"
    t.text "admin_received_contact"
    t.string "subject_email"
    t.text "order_generated_successfully"
    t.text "outstanding_installment"
    t.text "loss_access_delinquency"
    t.text "new_installment_order_generated"
  end

  create_table "company_pictures", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "photo"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_company_pictures_on_company_id"
  end

  create_table "company_videos", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_company_videos_on_company_id"
  end

  create_table "components", force: :cascade do |t|
    t.bigint "womb_id", null: false
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences"
    t.string "status"
    t.index ["womb_id"], name: "index_components_on_womb_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "status"
    t.text "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "course_announcements", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.text "image"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_announcements_on_course_id"
  end

  create_table "course_categories", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_course_categories_on_category_id"
    t.index ["course_id"], name: "index_course_categories_on_course_id"
  end

  create_table "course_collections", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "promotion_type", null: false
    t.bigint "promotion_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_collections_on_course_id"
    t.index ["promotion_type", "promotion_id"], name: "index_course_collections_on_promotion"
  end

  create_table "course_discounts", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "discount_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_discounts_on_course_id"
    t.index ["discount_id"], name: "index_course_discounts_on_discount_id"
  end

  create_table "course_essays", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "sent_type", null: false
    t.bigint "sent_id", null: false
    t.string "received_type", null: false
    t.bigint "received_id", null: false
    t.boolean "viewed"
    t.text "material"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "capsule_id", null: false
    t.index ["capsule_id"], name: "index_course_essays_on_capsule_id"
    t.index ["course_id"], name: "index_course_essays_on_course_id"
    t.index ["received_type", "received_id"], name: "index_course_essays_on_received"
    t.index ["sent_type", "sent_id"], name: "index_course_essays_on_sent"
  end

  create_table "course_free_links", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title"
    t.string "code"
    t.string "subcode"
    t.string "link"
    t.integer "period_access"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "url_video"
    t.text "one_day_finish_access"
    t.bigint "tag_id"
    t.text "content"
    t.index ["course_id"], name: "index_course_free_links_on_course_id"
    t.index ["tag_id"], name: "index_course_free_links_on_tag_id"
  end

  create_table "course_links", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title"
    t.string "code"
    t.string "subcode"
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "discount"
    t.index ["course_id"], name: "index_course_links_on_course_id"
  end

  create_table "course_notifications", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_notifications_on_course_id"
  end

  create_table "course_popups", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title"
    t.string "status", default: "inactive"
    t.string "link"
    t.text "image"
    t.text "image_mobile"
    t.text "content"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_popups_on_course_id"
  end

  create_table "course_related_student_areas", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "linked_type", null: false
    t.bigint "linked_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_related_student_areas_on_course_id"
    t.index ["linked_type", "linked_id"], name: "index_course_related_student_areas_on_linked"
  end

  create_table "course_relateds", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "linked_type", null: false
    t.bigint "linked_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_relateds_on_course_id"
    t.index ["linked_type", "linked_id"], name: "index_course_relateds_on_linked"
  end

  create_table "course_warranties", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_course_warranties_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.string "featured"
    t.string "status_disclosure"
    t.string "status_access"
    t.string "slug"
    t.string "value_of"
    t.string "value_installment"
    t.string "value_cash"
    t.string "installments"
    t.string "duration"
    t.string "supplementary_material"
    t.string "vacancies"
    t.string "nature"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "image"
    t.string "url"
    t.text "tags"
    t.string "link_hotmart"
    t.integer "period_access"
    t.boolean "signature", default: false
    t.string "essay_mentoring", default: "no"
    t.text "thirty_days_finish_access"
    t.text "ten_days_finish_access"
    t.text "one_day_finish_access"
    t.bigint "tag_id"
    t.boolean "recurrent", default: false
    t.boolean "use_chat", default: false
    t.integer "count_message_chat_gpt", default: 0
    t.string "kind", default: "usual"
    t.text "banner"
    t.text "description_banner"
    t.text "image_mobile"
    t.boolean "modal_discount", default: false
    t.boolean "lifetime", default: false
    t.boolean "view_banner_student_area", default: false
    t.boolean "unlimited_access", default: false
    t.index ["company_id"], name: "index_courses_on_company_id"
    t.index ["tag_id"], name: "index_courses_on_tag_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "active"
    t.boolean "validate_user", default: false
    t.index ["company_id"], name: "index_discounts_on_company_id"
  end

  create_table "email_logs", force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.string "email_type", null: false
    t.string "recipient_email", null: false
    t.string "status", default: "pending", null: false
    t.text "error_message"
    t.datetime "sent_at"
    t.text "mailer_response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_email_logs_on_payment_id"
  end

  create_table "error_chat_gpt_messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_error_chat_gpt_messages_on_user_id"
  end

  create_table "exams", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "faqs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "question"
    t.string "reply"
    t.string "status"
    t.integer "order", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_faqs_on_company_id"
  end

  create_table "free_link_accesses", force: :cascade do |t|
    t.bigint "course_free_link_id", null: false
    t.text "metadata"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_free_link_id"], name: "index_free_link_accesses_on_course_free_link_id"
  end

  create_table "free_link_user_courses", force: :cascade do |t|
    t.bigint "course_free_link_id", null: false
    t.bigint "user_course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_free_link_id"], name: "index_free_link_user_courses_on_course_free_link_id"
    t.index ["user_course_id"], name: "index_free_link_user_courses_on_user_course_id"
  end

  create_table "grades", force: :cascade do |t|
    t.bigint "participation_id", null: false
    t.bigint "assessment_subject_id", null: false
    t.decimal "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assessment_subject_id"], name: "index_grades_on_assessment_subject_id"
    t.index ["participation_id"], name: "index_grades_on_participation_id"
  end

  create_table "help_centers", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "information_chat_gpt_messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "instructors", force: :cascade do |t|
    t.string "name"
    t.text "photo"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "disclosure", default: false
    t.text "avatar"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.float "amount"
    t.integer "status"
    t.string "invoice_id"
    t.string "log_return_transaction"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
  end

  create_table "item_public_notices", force: :cascade do |t|
    t.text "title"
    t.bigint "stall_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["stall_id"], name: "index_item_public_notices_on_stall_id"
    t.index ["subject_id"], name: "index_item_public_notices_on_subject_id"
  end

  create_table "item_themes", force: :cascade do |t|
    t.bigint "item_public_notice_id", null: false
    t.bigint "subject_theme_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_public_notice_id"], name: "index_item_themes_on_item_public_notice_id"
    t.index ["subject_theme_id"], name: "index_item_themes_on_subject_theme_id"
  end

  create_table "item_topics", force: :cascade do |t|
    t.bigint "item_public_notice_id", null: false
    t.bigint "subject_theme_topic_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_public_notice_id"], name: "index_item_topics_on_item_public_notice_id"
    t.index ["subject_theme_topic_id"], name: "index_item_topics_on_subject_theme_topic_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "live_lesson_id", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["live_lesson_id"], name: "index_leads_on_live_lesson_id"
  end

  create_table "lecture_videos", force: :cascade do |t|
    t.bigint "lecture_id", null: false
    t.string "title"
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences"
    t.index ["lecture_id"], name: "index_lecture_videos_on_lecture_id"
  end

  create_table "lectures", force: :cascade do |t|
    t.bigint "component_id", null: false
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences"
    t.string "status"
    t.index ["component_id"], name: "index_lectures_on_component_id"
  end

  create_table "lesson_completed_pdfs", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.text "midia"
    t.string "order_sequences"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lesson_id"], name: "index_lesson_completed_pdfs_on_lesson_id"
  end

  create_table "lesson_contents", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.string "midia"
    t.string "order_sequences"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lesson_id"], name: "index_lesson_contents_on_lesson_id"
  end

  create_table "lesson_lecture_videos", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "lecture_video_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lecture_video_id"], name: "index_lesson_lecture_videos_on_lecture_video_id"
    t.index ["lesson_id"], name: "index_lesson_lecture_videos_on_lesson_id"
  end

  create_table "lesson_mind_maps", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.text "midia"
    t.string "order_sequences"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lesson_id"], name: "index_lesson_mind_maps_on_lesson_id"
  end

  create_table "lesson_review_womb_component_lectures", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "womb_id", null: false
    t.bigint "component_id", null: false
    t.bigint "lecture_id", null: false
    t.text "videos", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["component_id"], name: "index_lesson_review_womb_component_lectures_on_component_id"
    t.index ["lecture_id"], name: "index_lesson_review_womb_component_lectures_on_lecture_id"
    t.index ["lesson_id"], name: "index_lesson_review_womb_component_lectures_on_lesson_id"
    t.index ["womb_id"], name: "index_lesson_review_womb_component_lectures_on_womb_id"
  end

  create_table "lesson_summarized_pdfs", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.text "midia"
    t.string "order_sequences"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lesson_id"], name: "index_lesson_summarized_pdfs_on_lesson_id"
  end

  create_table "lesson_womb_component_lectures", force: :cascade do |t|
    t.bigint "lesson_id", null: false
    t.bigint "womb_id", null: false
    t.bigint "component_id", null: false
    t.bigint "lecture_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["component_id"], name: "index_lesson_womb_component_lectures_on_component_id"
    t.index ["lecture_id"], name: "index_lesson_womb_component_lectures_on_lecture_id"
    t.index ["lesson_id"], name: "index_lesson_womb_component_lectures_on_lesson_id"
    t.index ["womb_id"], name: "index_lesson_womb_component_lectures_on_womb_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "capsule_id", null: false
    t.string "title"
    t.text "description"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "release_period", default: 0
    t.integer "order_sequences", default: 0
    t.text "medias", default: [], array: true
    t.text "videos", default: [], array: true
    t.index ["capsule_id"], name: "index_lessons_on_capsule_id"
  end

  create_table "levels", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "link_accesses", force: :cascade do |t|
    t.bigint "course_link_id", null: false
    t.string "metadata"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_link_id"], name: "index_link_accesses_on_course_link_id"
  end

  create_table "link_payments", force: :cascade do |t|
    t.bigint "course_link_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_link_id"], name: "index_link_payments_on_course_link_id"
    t.index ["payment_id"], name: "index_link_payments_on_payment_id"
  end

  create_table "link_user_courses", force: :cascade do |t|
    t.bigint "course_link_id", null: false
    t.bigint "user_course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_link_id"], name: "index_link_user_courses_on_course_link_id"
    t.index ["user_course_id"], name: "index_link_user_courses_on_user_course_id"
  end

  create_table "live_lessons", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "title"
    t.string "status"
    t.string "url"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "material"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.text "description"
    t.string "url_course"
    t.index ["company_id"], name: "index_live_lessons_on_company_id"
  end

  create_table "log_changes", force: :cascade do |t|
    t.bigint "manager_id", null: false
    t.string "title"
    t.text "content"
    t.text "move"
    t.string "model"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["manager_id"], name: "index_log_changes_on_manager_id"
  end

  create_table "manager_access_groups", force: :cascade do |t|
    t.bigint "manager_id", null: false
    t.bigint "access_group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["access_group_id"], name: "index_manager_access_groups_on_access_group_id"
    t.index ["manager_id"], name: "index_manager_access_groups_on_manager_id"
  end

  create_table "managers", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "email"
    t.string "password"
    t.string "password_digest"
    t.index ["company_id"], name: "index_managers_on_company_id"
  end

  create_table "matters", force: :cascade do |t|
    t.string "title"
    t.bigint "course_id", null: false
    t.bigint "instructor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order_sequences"
    t.string "status", default: "active"
    t.string "access_period_type", default: "all"
    t.date "date_access_period"
    t.index ["course_id"], name: "index_matters_on_course_id"
    t.index ["instructor_id"], name: "index_matters_on_instructor_id"
  end

  create_table "order_courses", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "course_id", null: false
    t.string "discount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "value_cash"
    t.index ["course_id"], name: "index_order_courses_on_course_id"
    t.index ["order_id"], name: "index_order_courses_on_order_id"
  end

  create_table "order_installments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "payment_id"
    t.datetime "date_generate_payment"
    t.bigint "marker"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "error"
    t.index ["order_id"], name: "index_order_installments_on_order_id"
    t.index ["payment_id"], name: "index_order_installments_on_payment_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "manager_id", null: false
    t.string "payment_method"
    t.string "payment_installments"
    t.string "card_number"
    t.string "card_name"
    t.string "card_expiry"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "amount"
    t.float "installment_amount"
    t.float "discount"
    t.string "code"
    t.datetime "canceled_at"
    t.string "card_cvv"
    t.text "observation"
    t.string "canceled_name"
    t.float "first_installment_amount"
    t.boolean "lifetime", default: false
    t.integer "additional_time", default: 0
    t.string "status"
    t.index ["manager_id"], name: "index_orders_on_manager_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "participations", force: :cascade do |t|
    t.bigint "assessment_id", null: false
    t.bigint "user_id", null: false
    t.datetime "joined_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "open_file", default: false
    t.boolean "open_file_answer_comments", default: false
    t.index ["assessment_id"], name: "index_participations_on_assessment_id"
    t.index ["user_id"], name: "index_participations_on_user_id"
  end

  create_table "payment_utmifies", force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.text "log_return"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_payment_utmifies_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "course_id"
    t.bigint "user_id", null: false
    t.float "amount"
    t.string "method"
    t.string "duration"
    t.string "token"
    t.string "discount"
    t.integer "status"
    t.string "invoice_id"
    t.text "log_return_transaction"
    t.string "billet_line"
    t.string "billet_barcode"
    t.string "billet_qr_code"
    t.string "billet_pdf"
    t.datetime "billet_expiry_date"
    t.string "code"
    t.string "pix_qrcode"
    t.string "pix_qrcode_text"
    t.datetime "pix_expires_at"
    t.string "error"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "charge_id"
    t.boolean "handmade", default: false
    t.string "installments"
    t.boolean "send_message_pix_pending", default: false
    t.boolean "send_message_overdue", default: false
    t.datetime "date_overdue"
    t.boolean "closed", default: false
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.integer "cashback_applied_cents", default: 0, null: false
    t.index ["company_id"], name: "index_payments_on_company_id"
    t.index ["course_id"], name: "index_payments_on_course_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "question_themes", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "subject_theme_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_question_themes_on_question_id"
    t.index ["subject_theme_id"], name: "index_question_themes_on_subject_theme_id"
  end

  create_table "question_topics", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "subject_theme_topic_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_question_topics_on_question_id"
    t.index ["subject_theme_topic_id"], name: "index_question_topics_on_subject_theme_topic_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "title"
    t.bigint "subject_id", null: false
    t.string "year"
    t.bigint "stall_id", null: false
    t.bigint "exam_id", null: false
    t.bigint "position_id", null: false
    t.bigint "level_id", null: false
    t.string "item_public_notice"
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type_alternative"
    t.index ["exam_id"], name: "index_questions_on_exam_id"
    t.index ["level_id"], name: "index_questions_on_level_id"
    t.index ["position_id"], name: "index_questions_on_position_id"
    t.index ["stall_id"], name: "index_questions_on_stall_id"
    t.index ["subject_id"], name: "index_questions_on_subject_id"
  end

  create_table "rav_chat_messages", force: :cascade do |t|
    t.bigint "rav_chat_id", null: false
    t.text "question"
    t.text "answer"
    t.integer "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rav_chat_id"], name: "index_rav_chat_messages_on_rav_chat_id"
  end

  create_table "rav_chats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "code"
    t.string "thread"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_rav_chats_on_user_id"
  end

  create_table "report_whatsapp_messages", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_report_whatsapp_messages_on_company_id"
    t.index ["user_id"], name: "index_report_whatsapp_messages_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "file"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_reports_on_company_id"
  end

  create_table "site_advertisements", force: :cascade do |t|
    t.string "title"
    t.string "status", default: "inactive"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "link"
    t.text "image"
    t.text "content"
    t.integer "click", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "category", default: "initial_page"
    t.string "link_video"
  end

  create_table "stalls", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subject_theme_topics", force: :cascade do |t|
    t.bigint "subject_theme_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_theme_id"], name: "index_subject_theme_topics_on_subject_theme_id"
  end

  create_table "subject_themes", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_id"], name: "index_subject_themes_on_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.float "amount"
    t.string "method"
    t.string "duration"
    t.string "token"
    t.string "discount"
    t.integer "status"
    t.string "invoice_id"
    t.text "log_return_transaction"
    t.string "code"
    t.string "error"
    t.string "installments"
    t.boolean "send_message_pix_pending", default: false
    t.boolean "send_message_overdue", default: false
    t.datetime "date_overdue"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_subscriptions_on_company_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.integer "id_whatsapp_bot"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_tags_on_company_id"
  end

  create_table "teachers", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "about"
    t.text "sense"
    t.string "motivational_phrase"
    t.text "motivational_content"
    t.string "facebook"
    t.string "instagram"
    t.string "youtube"
    t.string "telegram"
    t.string "platform"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "genre"
    t.string "color"
    t.string "slogan"
    t.string "link_area_hotmart"
    t.string "link_area_aluno"
    t.index ["company_id"], name: "index_teachers_on_company_id"
  end

  create_table "terms_of_uses", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_terms_of_uses_on_company_id"
  end

  create_table "testimonial_media", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "nature"
    t.string "url"
    t.text "banner"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_testimonial_media_on_company_id"
  end

  create_table "testimonials", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "status"
    t.string "position"
    t.string "instagram"
    t.string "text"
    t.string "photo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_testimonials_on_company_id"
  end

  create_table "tip_chat_gpt_messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "street"
    t.string "posta_code"
    t.string "number"
    t.string "city"
    t.string "uf"
    t.string "neighborhood"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_addresses_on_user_id"
  end

  create_table "user_advertisements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "advertisement_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["advertisement_id"], name: "index_user_advertisements_on_advertisement_id"
    t.index ["user_id"], name: "index_user_advertisements_on_user_id"
  end

  create_table "user_course_notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_notification_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_notification_id"], name: "index_user_course_notifications_on_course_notification_id"
    t.index ["user_id"], name: "index_user_course_notifications_on_user_id"
  end

  create_table "user_course_popups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_popup_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_popup_id"], name: "index_user_course_popups_on_course_popup_id"
    t.index ["user_id"], name: "index_user_course_popups_on_user_id"
  end

  create_table "user_courses", force: :cascade do |t|
    t.bigint "payment_id"
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "access_until"
    t.date "access_start"
    t.boolean "lifetime", default: false
    t.string "discount"
    t.float "amount"
    t.boolean "authenticate", default: true
    t.bigint "subscription_id"
    t.index ["course_id"], name: "index_user_courses_on_course_id"
    t.index ["payment_id"], name: "index_user_courses_on_payment_id"
    t.index ["subscription_id"], name: "index_user_courses_on_subscription_id"
    t.index ["user_id"], name: "index_user_courses_on_user_id"
  end

  create_table "user_favorite_courses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_user_favorite_courses_on_course_id"
    t.index ["user_id"], name: "index_user_favorite_courses_on_user_id"
  end

  create_table "user_ips", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip"
    t.string "agent"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "checked", default: false
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "as"
    t.float "latitude"
    t.float "longitude"
    t.index ["user_id"], name: "index_user_ips_on_user_id"
  end

  create_table "user_lesson_lecture_videos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lesson_lecture_video_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lesson_lecture_video_id"], name: "index_user_lesson_lecture_videos_on_lesson_lecture_video_id"
    t.index ["user_id"], name: "index_user_lesson_lecture_videos_on_user_id"
  end

  create_table "user_lessons", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lesson_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["lesson_id"], name: "index_user_lessons_on_lesson_id"
    t.index ["user_id"], name: "index_user_lessons_on_user_id"
  end

  create_table "user_notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.text "content"
    t.boolean "viewed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_open_carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "send_whatsapp", default: false
    t.index ["course_id"], name: "index_user_open_carts_on_course_id"
    t.index ["user_id"], name: "index_user_open_carts_on_user_id"
  end

  create_table "user_tags", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tag_id"], name: "index_user_tags_on_tag_id"
    t.index ["user_id"], name: "index_user_tags_on_user_id"
  end

  create_table "user_terms_of_uses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "terms_of_use_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["terms_of_use_id"], name: "index_user_terms_of_uses_on_terms_of_use_id"
    t.index ["user_id"], name: "index_user_terms_of_uses_on_user_id"
  end

  create_table "user_tracks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.string "action"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_user_tracks_on_course_id"
    t.index ["user_id"], name: "index_user_tracks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "birth_date"
    t.string "cpf"
    t.string "phone"
    t.string "status"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "authentication_token", limit: 30
    t.boolean "use_chat", default: false
    t.string "thread_chat"
    t.string "last_ip"
    t.boolean "validate_ip", default: true
    t.text "photo"
    t.text "user_agent"
    t.integer "cashback_allowed_cents", default: 0, null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "whatsapp_messages", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.text "purchase_completed"
    t.text "purchase_pending_billet"
    t.text "purchase_pending_pix"
    t.text "purchase_cancelled_status"
    t.text "billet_generated_site"
    t.text "acquired_free_course"
    t.text "abandoned_purchase_cart"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "pix_and_billet_overdue"
    t.index ["company_id"], name: "index_whatsapp_messages_on_company_id"
  end

  create_table "whatsapp_send_rules", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.boolean "purchase_cancelled_status", default: false
    t.boolean "acquired_free_course", default: false
    t.boolean "order_generated_successfully", default: false
    t.boolean "new_installment_order_generated", default: false
    t.boolean "purchase_completed_payment", default: false
    t.boolean "purchase_completed_subscription", default: false
    t.boolean "billet_generated_site", default: false
    t.boolean "loss_access_delinquency", default: false
    t.boolean "outstanding_installment", default: false
    t.boolean "purchase_pending_billet", default: false
    t.boolean "purchase_pending_pix", default: false
    t.boolean "abandoned_purchase_cart", default: false
    t.boolean "pix_and_billet_overdue", default: false
    t.boolean "thirty_days_finish_access", default: false
    t.boolean "ten_days_finish_access", default: false
    t.boolean "one_day_finish_access", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_whatsapp_send_rules_on_company_id"
  end

  create_table "wombs", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alternatives", "questions"
  add_foreign_key "assessment_subjects", "assessments"
  add_foreign_key "assessments", "tags"
  add_foreign_key "banners", "companies"
  add_foreign_key "blog_courses", "blogs"
  add_foreign_key "blog_courses", "courses"
  add_foreign_key "blogs", "managers"
  add_foreign_key "campaign_users", "campaigns"
  add_foreign_key "capsules", "courses"
  add_foreign_key "capsules", "matters"
  add_foreign_key "cart_discounts", "companies"
  add_foreign_key "cashback_interests", "courses"
  add_foreign_key "cashback_interests", "users"
  add_foreign_key "cashback_movements", "payments"
  add_foreign_key "cashback_movements", "users"
  add_foreign_key "categories", "companies"
  add_foreign_key "chat_gpt_messages", "users"
  add_foreign_key "company_pictures", "companies"
  add_foreign_key "company_videos", "companies"
  add_foreign_key "components", "wombs"
  add_foreign_key "contacts", "companies"
  add_foreign_key "course_announcements", "courses"
  add_foreign_key "course_categories", "categories"
  add_foreign_key "course_categories", "courses"
  add_foreign_key "course_collections", "courses"
  add_foreign_key "course_discounts", "courses"
  add_foreign_key "course_discounts", "discounts"
  add_foreign_key "course_essays", "capsules"
  add_foreign_key "course_essays", "courses"
  add_foreign_key "course_free_links", "courses"
  add_foreign_key "course_free_links", "tags"
  add_foreign_key "course_links", "courses"
  add_foreign_key "course_notifications", "courses"
  add_foreign_key "course_popups", "courses"
  add_foreign_key "course_related_student_areas", "courses"
  add_foreign_key "course_relateds", "courses"
  add_foreign_key "course_warranties", "courses"
  add_foreign_key "courses", "companies"
  add_foreign_key "courses", "tags"
  add_foreign_key "discounts", "companies"
  add_foreign_key "email_logs", "payments"
  add_foreign_key "error_chat_gpt_messages", "users"
  add_foreign_key "faqs", "companies"
  add_foreign_key "free_link_accesses", "course_free_links"
  add_foreign_key "free_link_user_courses", "course_free_links"
  add_foreign_key "free_link_user_courses", "user_courses"
  add_foreign_key "grades", "assessment_subjects"
  add_foreign_key "grades", "participations"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "item_public_notices", "stalls"
  add_foreign_key "item_public_notices", "subjects"
  add_foreign_key "item_themes", "item_public_notices"
  add_foreign_key "item_themes", "subject_themes"
  add_foreign_key "item_topics", "item_public_notices"
  add_foreign_key "item_topics", "subject_theme_topics"
  add_foreign_key "leads", "live_lessons"
  add_foreign_key "lecture_videos", "lectures"
  add_foreign_key "lectures", "components"
  add_foreign_key "lesson_completed_pdfs", "lessons"
  add_foreign_key "lesson_contents", "lessons"
  add_foreign_key "lesson_lecture_videos", "lecture_videos"
  add_foreign_key "lesson_lecture_videos", "lessons"
  add_foreign_key "lesson_mind_maps", "lessons"
  add_foreign_key "lesson_review_womb_component_lectures", "components"
  add_foreign_key "lesson_review_womb_component_lectures", "lectures"
  add_foreign_key "lesson_review_womb_component_lectures", "lessons"
  add_foreign_key "lesson_review_womb_component_lectures", "wombs"
  add_foreign_key "lesson_summarized_pdfs", "lessons"
  add_foreign_key "lesson_womb_component_lectures", "components"
  add_foreign_key "lesson_womb_component_lectures", "lectures"
  add_foreign_key "lesson_womb_component_lectures", "lessons"
  add_foreign_key "lesson_womb_component_lectures", "wombs"
  add_foreign_key "lessons", "capsules"
  add_foreign_key "link_accesses", "course_links"
  add_foreign_key "link_payments", "course_links"
  add_foreign_key "link_payments", "payments"
  add_foreign_key "link_user_courses", "course_links"
  add_foreign_key "link_user_courses", "user_courses"
  add_foreign_key "live_lessons", "companies"
  add_foreign_key "log_changes", "managers"
  add_foreign_key "manager_access_groups", "access_groups"
  add_foreign_key "manager_access_groups", "managers"
  add_foreign_key "managers", "companies"
  add_foreign_key "matters", "courses"
  add_foreign_key "matters", "instructors"
  add_foreign_key "order_courses", "courses"
  add_foreign_key "order_courses", "orders"
  add_foreign_key "order_installments", "orders"
  add_foreign_key "order_installments", "payments"
  add_foreign_key "orders", "managers"
  add_foreign_key "orders", "users"
  add_foreign_key "participations", "assessments"
  add_foreign_key "participations", "users"
  add_foreign_key "payment_utmifies", "payments"
  add_foreign_key "payments", "companies"
  add_foreign_key "payments", "courses"
  add_foreign_key "payments", "users"
  add_foreign_key "question_themes", "questions"
  add_foreign_key "question_themes", "subject_themes"
  add_foreign_key "question_topics", "questions"
  add_foreign_key "question_topics", "subject_theme_topics"
  add_foreign_key "questions", "exams"
  add_foreign_key "questions", "levels"
  add_foreign_key "questions", "positions"
  add_foreign_key "questions", "stalls"
  add_foreign_key "questions", "subjects"
  add_foreign_key "rav_chat_messages", "rav_chats"
  add_foreign_key "rav_chats", "users"
  add_foreign_key "report_whatsapp_messages", "companies"
  add_foreign_key "report_whatsapp_messages", "users"
  add_foreign_key "reports", "companies"
  add_foreign_key "subject_theme_topics", "subject_themes"
  add_foreign_key "subject_themes", "subjects"
  add_foreign_key "subscriptions", "companies"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "tags", "companies"
  add_foreign_key "teachers", "companies"
  add_foreign_key "terms_of_uses", "companies"
  add_foreign_key "testimonial_media", "companies"
  add_foreign_key "testimonials", "companies"
  add_foreign_key "user_addresses", "users"
  add_foreign_key "user_advertisements", "advertisements"
  add_foreign_key "user_advertisements", "users"
  add_foreign_key "user_course_notifications", "course_notifications"
  add_foreign_key "user_course_notifications", "users"
  add_foreign_key "user_course_popups", "course_popups"
  add_foreign_key "user_course_popups", "users"
  add_foreign_key "user_courses", "courses"
  add_foreign_key "user_courses", "payments"
  add_foreign_key "user_courses", "subscriptions"
  add_foreign_key "user_courses", "users"
  add_foreign_key "user_favorite_courses", "courses"
  add_foreign_key "user_favorite_courses", "users"
  add_foreign_key "user_ips", "users"
  add_foreign_key "user_lesson_lecture_videos", "lesson_lecture_videos"
  add_foreign_key "user_lesson_lecture_videos", "users"
  add_foreign_key "user_lessons", "lessons"
  add_foreign_key "user_lessons", "users"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "user_open_carts", "courses"
  add_foreign_key "user_open_carts", "users"
  add_foreign_key "user_tags", "tags"
  add_foreign_key "user_tags", "users"
  add_foreign_key "user_terms_of_uses", "terms_of_uses"
  add_foreign_key "user_terms_of_uses", "users"
  add_foreign_key "user_tracks", "courses"
  add_foreign_key "user_tracks", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "whatsapp_messages", "companies"
  add_foreign_key "whatsapp_send_rules", "companies"
end
