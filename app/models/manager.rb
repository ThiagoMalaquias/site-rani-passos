class Manager < ApplicationRecord
  has_secure_password

  belongs_to :company
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid email' }

  has_many :manager_access_groups, dependent: :destroy
  has_many :log_changes, dependent: :destroy

  def is_admin?
    return @is_admin if @is_admin.present?

    mag = ManagerAccessGroup.where(manager: self)
    @is_admin = mag.map { |g| g.access_group.name.downcase }.include?("Admin")
    @is_admin
  end

  def accesses
    return @accesses if @accesses.present?

    accesses = manager_access_groups.map { |mag| mag.access_group.access_actions }
    @accesses = []
    accesses.each do |a|
      @accesses += a
    end
    @accesses
  end

  def accesses_include?(permission)
    accesses.each do |access|
      return true if access.include?(permission)
    end

    false
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
