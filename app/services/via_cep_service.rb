class ViaCepService
  require 'uri'
  require 'net/http'
  require 'openssl'

  def self.call!(cep)
    cep = cep.delete("-")
    url = URI("https://viacep.com.br/ws/#{cep}/json/")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    
    # Configuração SSL mais robusta
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = OpenSSL::X509::DEFAULT_CERT_FILE if File.exist?(OpenSSL::X509::DEFAULT_CERT_FILE)
    
    # Em desenvolvimento, permite desabilitar verificação se necessário
    if Rails.env.development? && ENV['DISABLE_SSL_VERIFY'] == 'true'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      Rails.logger.warn "⚠️  SSL verification disabled for ViaCEP (development only)"
    end

    request = Net::HTTP::Get.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    
    response = http.request(request)
    
    JSON.parse(response.read_body)
  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.error "SSL Error in ViaCEP: #{e.message}"
    raise
  rescue JSON::ParserError => e
    Rails.logger.error "JSON Parse Error in ViaCEP: #{e.message}"
    raise
  end
end