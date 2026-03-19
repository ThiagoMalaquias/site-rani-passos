class User::Tags::ExpiredCourse
  attr_accessor :user, :course

  def initialize(user_course)
    @user = user_course.user
    @course = user_course.course
  end

  def call!
    UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "AcessoExpirado"))
    UserTag.find_or_create_by(user: user, tag: course.tag) if course.tag_id.present?
  end
end
