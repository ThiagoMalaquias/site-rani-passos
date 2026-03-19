module ApplicationHelper
  def code(url)
    url.match(%r{youtube.com.*(?:/|v=)([^&$]+)})[1] rescue "0RptxXLf_FA"
  end

  def exist_in_cart?(site, id)
    cart_user = cookies["ead_#{site}_cart_user"]
    return false if cart_user.blank?

    JSON.parse(cart_user).any? { |item| item["id"] == id }
  end

  def count_course_in_cart(site)
    cart_user = cookies["ead_#{site}_cart_user"]
    return 0 if cart_user.blank?

    JSON.parse(cart_user).count
  end

  def encoded_code_discount(discount)
    require 'uri'

    return if discount.blank?

    URI.encode_www_form_component(discount)
  end

  def src_video_lesson(lecture_video)
    video = lecture_video.link

    if video.include?('pandavideo')
      return video
    elsif video.include?('youtube')
      code = video.split('?v=')[1]
      return "https://www.youtube.com/embed/#{code}"
    else
      return "https://player.vimeo.com/video/#{video.split('/')[3]}"
    end
  end
end
