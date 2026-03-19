class Whatsapp::Utils::HttpUtils
  BaseURL = "https://backend.botconversa.com.br/api/v1/webhook".freeze
  APIKEY = Rails.application.credentials.whatsapp_api_key

  def self.validate_use_service?
    APIKEY.present?
  end

  def self.http_request(url, method, data = nil)
    uri = URI("#{BaseURL}/#{url}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP.const_get(method).new(uri)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["API-KEY"] = APIKEY.to_s
    request.body = data.to_json if data

    response = http.request(request)
    JSON.parse(response.read_body) if response.read_body.present?
  end
end
