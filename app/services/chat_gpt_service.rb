class ChatGptService
  def initialize(message, thread_message = nil)
    @message = message
    @thread_message = thread_message
  end

  def call
    assistant = get_assistant
    thread_messages = @thread_message || create_thread_messages["id"]

    create_message(thread_messages)
    runs_thread_messages(thread_messages, assistant)

    message = fetch_assistant_message(thread_messages)
    [message, thread_messages]
  end

  private

  def get_assistant
    http_request("v1/assistants?order=desc&limit=20", "Get")["data"].first
  end

  def create_thread_messages
    http_request("v1/threads", "Post")
  end

  def create_message(thread_messages)
    data = {}
    data[:role] = "user"
    data[:content] = @message

    http_request("v1/threads/#{thread_messages}/messages", "Post", data)
  end

  def runs_thread_messages(thread_messages, assistant)
    data = {}
    data[:assistant_id] = assistant["id"]
    data[:instructions] = assistant["instructions"]

    http_request("v1/threads/#{thread_messages}/runs", "Post", data)
  end

  def get_message(thread_messages)
    http_request("v1/threads/#{thread_messages}/messages", "Get")
  end

  def fetch_assistant_message(thread_messages)
    message_content = ""

    loop do
      message = get_message(thread_messages)
      message_content = message.dig("data", 0, "content", 0, "text", "value")

      break message if message.dig("data", 0, "role") == "assistant" && message_content.present?

      sleep(2)
    end

    message_content
  end

  def http_request(url, method, data = nil)
    uri = URI("https://api.openai.com/#{url}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP.const_get(method).new(uri)
    request["Accept"] = 'application/json'
    request["OpenAI-Beta"] = 'assistants=v1'
    request["Content-Type"] = 'application/json'
    request["Authorization"] = "Bearer #{Rails.application.credentials.chat_gpt_key}"
    request.body = data.to_json if data

    response = http.request(request)
    JSON.parse(response.read_body) if response.read_body.present?
  end
end
