class BlogCourse < ApplicationRecord
  belongs_to :blog
  belongs_to :course
end
