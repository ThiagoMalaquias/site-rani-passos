class Company < ApplicationRecord
  has_one :teacher, dependent: :destroy
  has_one :whatsapp_message, dependent: :destroy
  has_one :whatsapp_send_rule, dependent: :destroy

  has_many :faqs, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :menus, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :banners, dependent: :destroy
  has_many :courses, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :managers, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :discounts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :testimonials, dependent: :destroy
  has_many :live_lessons, dependent: :destroy
  has_many :terms_of_uses, dependent: :destroy
  has_many :cart_discounts, dependent: :destroy
  has_many :report_whatsapp_messages, dependent: :destroy
  has_many :testimonial_media, dependent: :destroy
  has_many :videos, class_name: :CompanyVideo, dependent: :destroy
  has_many :pictures, class_name: :CompanyPicture, dependent: :destroy
end
