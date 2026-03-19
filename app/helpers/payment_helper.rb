module PaymentHelper
  ALLOWED_CASHBACK_COURSE_IDS = [48, 504, 433].freeze

  def permit_courses_cashback(_user, courses)
    courses.any? { |course| ALLOWED_CASHBACK_COURSE_IDS.include?(course.id) }
  end
end