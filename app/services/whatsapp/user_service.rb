class Whatsapp::UserService
  attr_reader :user
  
  def initialize(user)
    @user = user
  end

  def call!
    return unless user.phone.present?

    subscriber = find_subscriber_by_phone(false)
    subscriber = find_subscriber_by_phone(true) if subscriber.empty?
    subscriber = create_subscriber if subscriber.empty?
    subscriber
  end

  private

  def phone_format_without_ninth_digit
    ddd = user.phone.gsub(/[\s\-()]/, '')[0, 2]
    phone = user.phone[6, 14].delete("-")

    "+55#{ddd}#{phone}"
  end

  def phone_format_with_ninth_digit
    "+55#{user.phone.gsub(/[\s\-()]/, '')}"
  end

  def find_subscriber_by_phone(ninth_digit = false)
    formated_phone = phone_format_with_ninth_digit if ninth_digit
    formated_phone = phone_format_without_ninth_digit if formated_phone.nil?

    url = "subscriber/get_by_phone/#{formated_phone}/"
    Whatsapp::Utils::HttpUtils.http_request(url, "Get")
  end

  def create_subscriber
    user_name_split = user.name.split
    first_name = user_name_split.first
    last_name = user_name_split.last

    data = { phone: phone_format_with_ninth_digit, first_name: first_name, last_name: last_name }
    url = "subscriber/"
    Whatsapp::Utils::HttpUtils.http_request(url, "Post", data)
  end
end
