class EmailLog < ApplicationRecord
  belongs_to :payment

  enum status: { pending: 0, success: 1, failed: 2 }

  scope :purchase_emails, -> { where(email_type: 'purchase_course') }
  scope :successful, -> { where(status: 'success') }
  scope :failed, -> { where(status: 'failed') }
  scope :recent, -> { order(created_at: :desc) }

  validates :email_type, presence: true
  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def mark_as_success!(response = nil)
    update!(
      status: :success,
      sent_at: Time.current,
      mailer_response: response&.to_json
    )
  end

  def mark_as_failed!(error_message)
    update!(
      status: :failed,
      error_message: error_message,
      sent_at: Time.current
    )
  end
end