class TagBotJob < ApplicationJob
  queue_as :integrations

  def perform(user_id, tag_id, action)
    user = User.find(user_id)
    tag = Tag.find(tag_id)

    if action == :apply
      Whatsapp::TagService.new.create(user, Tag.find_by(name: "NomeConfirmado").id_whatsapp_bot)
      Whatsapp::TagService.new.create(user, tag.id_whatsapp_bot)
    else
      Whatsapp::TagService.new.destroy(user, tag.id_whatsapp_bot)
    end

    user.synchronize_tags
  end
end
