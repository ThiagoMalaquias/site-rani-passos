class Subject < ApplicationRecord
  has_many :themes, class_name: :SubjectTheme, dependent: :destroy
end
