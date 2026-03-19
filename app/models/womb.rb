class Womb < ApplicationRecord
  has_many :components, dependent: :destroy
end
