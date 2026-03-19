class Banner < ApplicationRecord
  belongs_to :company

  has_one_attached :image
  has_one_attached :image_mobile

  scope :actives, -> { where('status = ? and start_date < ?', 'active', Time.zone.now) }

  def date_is_valid?
    return true if end_date.blank?

    end_date > Time.zone.now
  end

  private

  after_create do
    LogChange.save_log("Inclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_update do
    LogChange.save_log("Alteração de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  before_destroy do
    LogChange.save_log("Exclusão de registro (#{self.class})", atributos_log, self.class.to_s, changes.except(:updated_at))
  end

  def atributos_log
    attributes.except("updated_at", "created_at")
  end
end
