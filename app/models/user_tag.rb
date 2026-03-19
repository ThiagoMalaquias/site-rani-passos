class UserTag < ApplicationRecord
  belongs_to :user
  belongs_to :tag

  after_create :apply_tag_in_bot
  before_destroy :remove_tag_in_bot

  private

  def apply_tag_in_bot
    TagBotJob.set(wait: 20.minutes).perform_later(user.id, tag.id, :apply)
  end

  def remove_tag_in_bot
    TagBotJob.set(wait: 20.minutes).perform_later(user.id, tag.id, :remove)
  end
end
