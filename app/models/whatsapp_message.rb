class WhatsappMessage < ApplicationRecord
  belongs_to :company

  def self.send_text(user, table_column, model = nil, substitutions = [])
    return if free_course?(model)

    object = (model.presence || first)
    message = object.send(table_column.to_sym)
    return if message.nil?

    message = ActionView::Base.full_sanitizer.sanitize(message, tags: [])
    substitutions.each do |substitution|
      message = message.gsub((substitution[:name]).to_s, substitution[:text])
    end

    ReportWhatsappMessage.create(company: Company.first, user: user, content: message)

    WhatsappJob.set(wait: 10.minutes).perform_later(user.id, message)
  end

  private

  def self.free_course?(model)
    return false if model.nil?
    return false if model.class != Course

    model.nature == "free"
  end
end
