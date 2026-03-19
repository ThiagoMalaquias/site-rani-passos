class Payment::CashbackInterestService
  Result = Struct.new(
    :success?,
    :error_message,
    :notice,
    :payment_user_id,
    :cashback_applied,
    :cart_courses,
    keyword_init: true
  )

  def initialize(user_id:, authentication_token:, course_id:, cookies_course:, site:)
    @user_id = user_id
    @authentication_token = authentication_token
    @course_id = course_id
    @cookies_course = cookies_course
    @site = site
  end

  def call
    return failure("Usuário ou curso inválido.") if user.blank? || course.blank?

    if user.cashback_balance_cents <= 0
      return failure("Você não tem saldo de cashback suficiente para aplicar.")
    end

    success_result
  end

  private

  attr_reader :user_id, :authentication_token, :course_id, :cookies_course, :site

  def user
    @user ||= User.find_by(id: user_id, authentication_token: authentication_token)
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def updated_cart_courses
    courses = Array.wrap(cookies_course)
    courses << { "id" => course.id, "local" => "", "discount" => "", "code" => 0 }
    courses.uniq { |item| item["id"] }
  end

  def success_result
    Result.new(
      success?: true,
      error_message: nil,
      notice: "O saldo de cashback foi aplicado com sucesso.",
      payment_user_id: user.id.to_s,
      cashback_applied: true,
      cart_courses: updated_cart_courses
    )
  end

  def failure(message)
    Result.new(
      success?: false,
      error_message: message,
      notice: nil,
      payment_user_id: nil,
      cashback_applied: false,
      cart_courses: cookies_course
    )
  end
end