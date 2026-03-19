class FreeLinkUserCourse < ApplicationRecord
  belongs_to :course_free_link
  belongs_to :user_course

  scope :inicial_accesses, ->(start_date, end_date) { where("TO_CHAR(user_courses.access_start::date, 'YYYY-MM-DD') >= ? and TO_CHAR(user_courses.access_start::date,'YYYY-MM-DD') <= ?", start_date, end_date) }

  scope :user_purchase_course, ->(course_id) { 
    select(
      'free_link_user_courses.*',
      "EXISTS (
        SELECT 1 FROM user_courses
        WHERE user_courses.user_id = users.id
          AND user_courses.course_id = #{course_id}
          AND user_courses.payment_id IS NOT NULL
      ) AS user_purchase_course"
    )
  }
end
