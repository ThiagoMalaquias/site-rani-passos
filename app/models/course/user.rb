class Course::User
  def initialize(user)
    @user = user
  end

  def courses
    Course
      .joins(user_courses: :user)
      .where("user_courses.status = 'active'
        and (user_courses.access_until > '#{Time.zone.now.strftime('%Y-%m-%d')}' or user_courses.lifetime = true)
        and user_courses.user_id = #{@user.id}
        and user_courses.authenticate = true
        and courses.status_access = 'active'")
  end

  def courses_student_area
    ids_courses = []
    courses.find_each do |course|
      if course.signature
        ids_courses.concat(Course.courses_bind_signature(course).map(&:id))
      else
        ids_courses.push(course.id)
      end
    end

    Course.where(id: ids_courses.uniq)
  end

  def courses_with_notifications
    ids_courses = []
    courses.find_each do |course|
      ids_courses.push(course.id)
      next unless course.signature

      ids_courses.concat(Course.courses_bind_signature(course).map(&:id))
    end

    Course.where(id: ids_courses.uniq)
  end
end
