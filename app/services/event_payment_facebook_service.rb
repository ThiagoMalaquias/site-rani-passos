class EventPaymentFacebookService
  require 'digest'

  def initialize(payment)
    @payment = payment
  end

  def call
    options = {}
    options[:data] = []

    @payment.user_courses.non_nil_amount.each do |user_course|
      options[:data] << { 
        event_name: event_name_for_course(user_course.course), 
        event_time: Time.current.to_i, 
        event_id: "order_#{@payment.id}_#{user_course.id}", 
        action_source: "website", 
        user_data: user_data_hash, 
        custom_data: { 
          currency: "BRL", 
          value: user_course.amount, 
          content_name: user_course.course.title, 
          content_ids: [user_course.course.id], 
          content_type: "product" 
        } 
      } 
    end

    change_order(options)
  end

  private

  def event_name_for_course(course)
    course_title = course.title.titleize.gsub(/\s+/, '_')
    "Comprou_Curso_#{course_title}"
  end

  def user_data_hash
    user = @payment.user
    
    {
      em: hash_sha256(user.email&.downcase&.strip),
      ph: hash_sha256(user.without_mask("total_number")),
      client_ip_address: user.last_ip,
      client_user_agent: user.user_agent
    }
  end

  def hash_sha256(value)
    return nil if value.blank?
    
    Digest::SHA256.hexdigest(value.to_s.strip.downcase)
  end

  def change_order(options)
    url = URI("https://graph.facebook.com/v25.0/197288153080245/events?access_token=#{Rails.application.credentials.facebook_conversion_api_token}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request.body = options.to_json
    response = http.request(request)

    JSON.parse(response.read_body)
  end
end