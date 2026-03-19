class User < ApplicationRecord
  belongs_to :company
  has_many :addresses, class_name: "UserAddress", dependent: :destroy
  has_many :open_carts, class_name: "UserOpenCart", dependent: :destroy
  has_many :course_notifications, class_name: "UserCourseNotification", dependent: :destroy
  has_many :notifications, class_name: "UserNotification", dependent: :destroy
  has_many :favorite_courses, class_name: "UserFavoriteCourse", dependent: :destroy
  has_many :ips, class_name: "UserIp", dependent: :destroy
  has_many :tracks, class_name: "UserTrack", dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :chat_gpt_messages, dependent: :destroy
  has_many :error_chat_gpt_messages, dependent: :destroy
  has_many :report_whatsapp_messages, dependent: :destroy
  has_many :course_essays, as: :sent, class_name: 'CourseEssay', dependent: :destroy
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags
  has_many :user_lesson_lecture_videos, dependent: :destroy
  has_many :rav_chats, dependent: :destroy
  has_many :cashback_movements, dependent: :destroy
  has_many :user_terms_of_uses, dependent: :destroy
  has_many :terms_of_uses, through: :user_terms_of_uses
  has_many :cashback_interests, dependent: :destroy

  validates :name, :email, :cpf, :phone, presence: true
  validates :email, :cpf, uniqueness: true
  validate :validate_cpf

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  scope :actives, -> { where(status: 'active') }
  scope :inactives, -> { where(status: 'inactive') }
  scope :with_tags, -> (tag_ids) { 
    joins(:user_tags)
      .where(user_tags: { tag_id: tag_ids })
      .group('users.id')
      .having('COUNT(DISTINCT user_tags.tag_id) = ?', tag_ids.size)
  }
  scope :without_tags, -> (tag_ids) { 
    where
    .not(
      id: User.joins(:user_tags)
              .where(user_tags: { tag_id: tag_ids })
              .select(:id)
    )
  }

  def set_address(address_params)
    posta_code = address_params[:posta_code]
    return "CEP não pode ficar em branco" if posta_code.blank?
    return "CEP é inválido" unless valid_posta_code?(posta_code)

    address = addresses.find_or_create_by(posta_code: posta_code)
    address.update(address_params)
  end

  def without_mask(collum)
    case collum
    when "cpf"
      return cpf.to_s.scan(/\d/).join
    when "area_code"
      return phone.delete("()").split[0]
    when "number"
      return phone.split[1].to_s.scan(/\d/).join
    when "total_number"
      return phone.gsub(/[\s\-()]/, '')
    end
  end

  def courses
    Course::User.new(self).courses
  end

  def courses_student_area
    Course::User.new(self).courses_student_area
  end

  def courses_open_carts
    open_carts
      .select('user_open_carts.course_id, courses.title').distinct
      .joins(:course)
  end

  def track_carts(course_id)
    open_carts
      .where(course_id: course_id)
      .order("created_at asc")
  end

  def synchronize_tags
    tags_boot = Whatsapp::TagService.new.get_by_user(self)
    return if tags_boot.blank?

    tags_boot.each do |tag_name_bot|
      tag = Tag.find_by(name: tag_name_bot)
      user_tags.find_or_create_by(tag: tag) if tag.present?
    end
  end

  def approve_last_term
    terms_of_use = TermsOfUse.last
    return false if terms_of_use.nil?

    user_terms_of_uses.find_by(terms_of_use: terms_of_use).present?
  end

  def track_courses
    Course.joins(:user_tracks).where(user_tracks: { user_id: id }).distinct
  end

  def all_notifications
    courses = Course::User.new(self).courses_with_notifications
    course_ids = courses.map(&:id)
    return [] if course_ids.blank?

    course_notification_ids = course_notifications.map(&:course_notification_id)
    date = Time.zone.now.strftime("%Y-%m-%d")

    query = ""
    query += "course_notifications.id not in (#{course_notification_ids.join(',')}) and" if course_notification_ids.count.positive?

    result = ActiveRecord::Base.connection.execute("
      select * from (
        SELECT course_notifications.id as id, course_notifications.created_at as created_at, course_notifications.content as content, courses.title as course_title, 'course' as direction
        FROM course_notifications
        INNER JOIN courses ON courses.id = course_notifications.course_id
        WHERE #{query}
          course_notifications.course_id in (#{course_ids.join(',')}) and
          course_notifications.start_date <= '#{date}' and course_notifications.end_date >= '#{date}'
        UNION
        SELECT id, created_at, content, null as course_title, 'user' as direction
        FROM user_notifications
        WHERE user_notifications.user_id = #{id}
          and user_notifications.viewed = false
          and user_notifications.start_date <= '#{date}' and user_notifications.end_date >= '#{date}'
      ) as notifications
      order by created_at desc
    ")

    result.to_a
  end

  def essays
    result = ActiveRecord::Base.connection.execute("
      SELECT id, created_at FROM course_essays
      WHERE sent_id = #{id} and sent_type = 'User'
      UNION
      SELECT id, created_at FROM course_essays
      WHERE received_id = #{id} and received_type = 'User'
    ")

    result.to_a
  end

  def ip_status
    User::Ips.new({ user_id: id }).execute.first["status"] rescue "normal"
  end

  def cart_course_names
    courses_open_carts.pluck('courses.title').join(", ")
  end

  def cashback_balance_cents
    cashback_movements.sum(:amount_cents)
  end

  def cashback_usable_cents
    cashback_balance_cents
  end

  private

  def valid_posta_code?(posta_code)
    via_return = ViaCepService.call!(posta_code)
    via_return['erro'].blank?
  end

  def validate_cpf
    require 'cpf_cnpj'
    return if cpf.blank?

    errors.add(:base, "CPF inválido") unless CPF.valid?(cpf)
  end

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
    attributes.except("updated_at", "created_at", "birth_date", "reset_password_token", "reset_password_sent_at", "remember_created_at", "sign_in_count", "current_sign_in_at", "last_sign_in_at", "current_sign_in_ip", "last_sign_in_ip",
                      "encrypted_password", "authentication_token")
  end
end
