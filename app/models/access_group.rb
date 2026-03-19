class AccessGroup < ApplicationRecord
  has_many :manager_access_groups, dependent: :destroy

  after_save :save_manager

  def access_parse
    access.present? ? JSON.parse(access) : []
  rescue
    []
  end

  def access_actions
    access_parse.pluck("access")
  rescue
    []
  end

  def access_views
    access_parse.pluck("access").uniq.compact.flatten
  rescue
    []
  end

  def managers=(value)
    @managers_ids = value
  end

  def managers
    return @managers if @managers.present?

    @managers = manager_access_groups.map { |mag| mag.manager.id }
    @managers
  end

  private

  def save_manager
    ManagerAccessGroup.where(access_group: self).find_each(&:destroy)
    return if @managers_ids.blank?

    @managers_ids.each do |manager_id|
      ManagerAccessGroup.create(manager_id: manager_id, access_group: self)
    end
  end
end
