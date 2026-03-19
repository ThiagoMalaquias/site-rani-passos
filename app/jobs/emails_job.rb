class EmailsJob < ApplicationJob
  queue_as :critical

  retry_on Net::SMTPServerBusy, wait: :exponentially_longer, attempts: 5
  retry_on Timeout::Error, wait: 5.minutes, attempts: 3

  def perform(payment_id)
    payment = Payment.find(payment_id)
    
    email_log = EmailLog.create!(
      payment: payment,
      email_type: 'purchase_course',
      recipient_email: payment.user.email,
      status: :pending
    )

    begin
      mail = EmailsMailer.purchase_course(payment)
      response = mail.deliver
      
      email_log.mark_as_success!(response)
    rescue => e
      email_log.mark_as_failed!(e.message)
      
      raise
    end
  end
end