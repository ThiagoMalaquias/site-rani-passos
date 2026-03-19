class UserOpenCart < ApplicationRecord
  belongs_to :user
  belongs_to :course

  after_update :on_update_verify_tags
  after_destroy :on_destroy_verify_tags

  scope :not_send_whatsapp, -> { where(send_whatsapp: false) }

  def on_destroy_verify_tags
    verify_tags(true)
  end

  def on_update_verify_tags
    verify_tags
  end

  private

  def verify_tags(destroying = false)
    User::Tags::AbandonedCart.new(self, destroying).call!
  end
end
