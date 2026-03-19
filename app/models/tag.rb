class Tag < ApplicationRecord
  belongs_to :company

  def self.update_all_whatsapp(company)
    tags_bot_whatsapp = Whatsapp::TagService.new.get
    tags_bot_whatsapp.each do |tag_bot_whatsapp|
      tag = find_or_create_by(company: company, id_whatsapp_bot: tag_bot_whatsapp["id"])
      tag.update(name: tag_bot_whatsapp["name"])
    end
  end
end
