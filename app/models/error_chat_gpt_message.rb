class ErrorChatGptMessage < ApplicationRecord
  belongs_to :user

  after_create_commit { send_message_whatsapp }

  def send_message_whatsapp
    message = "*Olá Rani. Um Aluno reportou um erro no Chat-RavI:* #{content}"
    user = User.find(678)

    WhatsappJob.set(wait: 10.minutes).perform_later(user.id, message)
  end
end
