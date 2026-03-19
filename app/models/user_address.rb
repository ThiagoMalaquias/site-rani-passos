class UserAddress < ApplicationRecord
  belongs_to :user

  validates :posta_code, :street, :city, :uf, :number, :neighborhood, presence: true
end
