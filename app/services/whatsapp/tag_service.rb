class Whatsapp::TagService
  def initialize
    return if Whatsapp::Utils::HttpUtils.validate_use_service?
  end

  def get
    url = "tags/"
    Whatsapp::Utils::HttpUtils.http_request(url, "Get")
  end

  def get_by_user(user)
    subscriber = Whatsapp::UserService.new(user).call!
    subscriber["tags"] if subscriber.present?
  end

  def create(user, tag_id)
    subscriber = Whatsapp::UserService.new(user).call!
    url = "subscriber/#{subscriber['id']}/tags/#{tag_id}/"
    Whatsapp::Utils::HttpUtils.http_request(url, "Post", {})
  end

  def destroy(user, tag_id)
    subscriber = Whatsapp::UserService.new(user).call!
    url = "subscriber/#{subscriber['id']}/tags/#{tag_id}/"
    Whatsapp::Utils::HttpUtils.http_request(url, "Delete")
  end
end
