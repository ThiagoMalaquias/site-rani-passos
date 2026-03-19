class Blog < ApplicationRecord
  has_one_attached :image

  belongs_to :manager
  has_many :blog_courses, dependent: :destroy
  has_many :courses, through: :blog_courses

  before_save :add_style_to_images
  after_save :verify_slug

  scope :actives, -> { where(status: 'active') }

  private

  def verify_slug
    return if slug.present?

    self.slug = "#{title.parameterize}-#{id}"
    save
  end

  def add_style_to_images
    require 'nokogiri'
    return if content.blank?
    
    doc = Nokogiri::HTML.fragment(content)
    doc.css('img').each do |img|
      img['style'] = 'width: 100%;'
    end

    iframes = doc.css('iframe')
    iframes.each do |iframe|
      iframe.remove_attribute('width')
      iframe.remove_attribute('height')
      
      div_container = Nokogiri::XML::Node.new('div', doc)
      div_container['class'] = 'video-container'
      
      div_container << iframe.clone
      iframe.replace(div_container)
    end
  
    self.content = doc.to_html
  end
end
