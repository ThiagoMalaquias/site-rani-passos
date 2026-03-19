class EmailsMailer < ApplicationMailer
  def received_contact(contact)
    company = contact.company
    @body = company.acknowledgment.gsub("{{user_name}}", contact.name)

    mail(to: contact.email, subject: "Recebemos seu contato", template_name: "email")
  end

  def purchase_course(payment)
    company = payment.company
    user = payment.user
    user_courses = payment.user_courses
    amount = payment.amount / 100.to_f

    access_until = 12.months.from_now

    @body = company.message_email.gsub("{{user_name}}", user.name) rescue ""
    @body = @body.gsub("{{payment_code}}", payment.code)
    @body = @body.gsub("{{course_title}}", user_courses.titles)
    @body = @body.gsub("{{payment_amount}}", format('%.2f', amount).tr('.', ','))
    @body = @body.gsub("{{payment_method}}", payment.method_pt)
    @body = @body.gsub("{{payment_created_at}}", payment.created_at.strftime("%d/%m/%Y"))
    @body = @body.gsub("{{access_until}}", access_until.strftime("%d/%m/%Y"))
    @body = @body.gsub("{{user_email}}", user.email)

    mail(to: user.email, subject: company.subject_email.to_s, template_name: "email")
  end

  def access_free_course(user_course)
    company = user_course.course.company

    @body = company.message_email_course_free
    @body = @body.gsub("{{user_name}}", user_course.user.name)
    @body = @body.gsub("{{user_email}}", user_course.user.email)
    @body = @body.gsub("{{course_title}}", user_course.course.title)
    @body = @body.gsub("{{access_until}}", user_course.access_until.strftime("%d/%m/%Y"))

    mail(to: user_course.user.email, subject: "B#{company.subject_email}", template_name: "email")
  end

  def reset_password_instructions(user)
    company = user.company

    link_reset_password = "#{user.authentication_token}/#{SecureRandom.uuid}/reset_password"
    @body = company.reset_password_instructions
    @body = @body.gsub("{{user_name}}", user.name)
    @body = @body.gsub("{{link_reset_password}}", link_reset_password)

    email_log_id = SecureRandom.uuid

    headers['X-SMTPAPI'] = {
      unique_args: {
        user_id: user.id,
        company_id: company.id,
        email_log_id: email_log_id,
        mailer: 'EmailsMailer#reset_password_instructions',
        env: Rails.env
      }
    }.to_json

    mail(to: user.email,
         subject: "Recuperação de Conta",
         template_name: "email")
  end

  def admin_received_contact(contact)
    company = contact.company

    @body = company.admin_received_contact
    @body = @body.gsub("{{contact_name}}", contact.name)
    @body = @body.gsub("{{contact_email}}", contact.email)
    @body = @body.gsub("{{contact_phone}}", contact.phone)
    @body = @body.gsub("{{contact_message}}", contact.message)

    mail(to: Teacher.first.email.to_s, subject: "Novo Contato Enviado", template_name: "email")
  end

  def campaign_email(user, campaign)
    @user = user
    @campaign = campaign
    @content = campaign.content
    @teacher = Teacher.first

    email_log_id = SecureRandom.uuid
    user.update(message_id: email_log_id)

    headers['X-SMTPAPI'] = {
      unique_args: {
        campaign_id: campaign.id,
        email_log_id: email_log_id,
        mailer: 'EmailsMailer#campaign_email',
        env: Rails.env
      }
    }.to_json

    mail(to: user.email, subject: campaign.subject, template_name: 'campaign_email')
  end

  def campaign_email_test(email, campaign)
    @campaign = campaign
    @content = campaign.content
    @teacher = Teacher.first

    mail(to: email, subject: campaign.subject, template_name: 'campaign_email')
  end
end
