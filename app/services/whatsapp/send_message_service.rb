class Whatsapp::SendMessageService
  def initialize(user, message)
    @user = user
    @message = message
  end

  def call!
    return unless Whatsapp::Utils::HttpUtils.validate_use_service?

    subscriber = Whatsapp::UserService.new(@user).call!

    send_message_to_subscriber(subscriber)
  end

  private

  def send_message_to_subscriber(subscriber)
    data = { type: "text", value: @message }
    url = "subscriber/#{subscriber['id']}/send_message/"
    Whatsapp::Utils::HttpUtils.http_request(url, "Post", data)
  end
end
