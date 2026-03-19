class WhatsappJob < ApplicationJob
  queue_as :integrations

  def perform(user_id, message)
    user = User.find(user_id)

    Whatsapp::SendMessageService.new(user, message).call!
  end
end
