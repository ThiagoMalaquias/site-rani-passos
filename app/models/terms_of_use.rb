class TermsOfUse < ApplicationRecord
  belongs_to :company

  has_many :user_terms_of_uses, dependent: :destroy
  has_many :users, through: :user_terms_of_uses
end
