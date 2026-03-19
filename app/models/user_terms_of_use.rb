class UserTermsOfUse < ApplicationRecord
  belongs_to :user
  belongs_to :terms_of_use
end
