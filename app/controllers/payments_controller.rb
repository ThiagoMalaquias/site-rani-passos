class PaymentsController < ApplicationController
  before_action :require_cart_cookies, only: [:new, :create]
  before_action :get_user_from_payment_user_id, only: [:create]
  before_action :set_payment, only: [:show, :thanks]
  skip_before_action :verify_authenticity_token, only: [:create, :status_webhook]

  def thanks
    @user = @payment.user
    apply_code_metrics_if_present
  end

  def show
    return head :not_found if @payment.blank?

    render json: payment_json, status: :ok
  end

  def new
    @courses = cart.courses
    @total_amount = cart.total_amount
    @all_installments = cart.all_installments
    @main_course_cart_line = cookies_course.find { |c| @courses.first && c["id"].to_i == @courses.first.id }

    if payment_user_id.blank?
      @user = User.new(
        name: cookies[:user_name],
        email: cookies[:user_email],
        phone: cookies[:user_phone]
      )
    else
      @user = User.find_by(id: payment_user_id)
    end
  end

  def create
    result = Payment::CreateOrderService.new(
      company: company,
      cookies_course: cookies_course,
      user_id: payment_user_id,
      payment_params: payment_params,
      cashback_applied: params[:cashback_applied],
      utm_cookies: utm_cookies,
      site: @site
    ).call

    if result.success?
      clear_cart_cookie
      redirect_to "/payments/thanks/#{result.payment.code}"
    else
      notify_purchase_cancelled_if_configured
      flash[:error] = result.error
      redirect_to new_payment_path
    end
  end

  def status_webhook
    if Payment.status_webhook(params["data"])
      render json: {}, status: :ok
    else
      render json: {}, status: :not_found
    end
  rescue StandardError => e
    Rails.logger.error("[PaymentsController#status_webhook] #{e.message}\n#{e.backtrace.first(10).join("\n")}")
    render json: {}, status: :unauthorized
  end

  private

  def get_user_from_payment_user_id
    return if cookies[:payment_user].present?

    @user = User::Site::Create.new(company, user_params, address_params).call!

    unless @user.instance_of?(User)
      flash[:error] = @user[:message_error]
      redirect_to new_payment_path
      return
    end

    @user.update(user_params.merge(last_ip: request.remote_ip, user_agent: request.user_agent))
    cookies[:payment_user] = @user.id.to_s

    cookies_course.each do |cc|
      course = Course.find(cc["id"])
      UserOpenCart.create(user: @user, course: course)
    end

    @user.id
  end

  def require_cart_cookies
    return if cookies["ead_#{@site}_cart_user"].present?

    redirect_to root_path
  end

  def set_payment
    @payment = Payment.find_by(code: params[:code])
  end

  def payment_user_id
    cookies[:payment_user].presence
  end

  def payment_params
    params.permit(
      :method,
      :token,
      :installments,
      card: %i[number name expiry cvc]
    )
  end

  def utm_cookies
    {
      utm_source: cookies[:utm_source],
      utm_medium: cookies[:utm_medium],
      utm_campaign: cookies[:utm_campaign],
      origin: cookies[:origin]
    }
  end

  def apply_code_metrics_if_present
    return if cookies[:ead_code_metrics].blank?

    code = cookies[:ead_code_metrics]
    course_link = CourseLink.find_by(code: code)
    if course_link
      LinkPayment.find_or_create_by(course_link: course_link, payment: @payment)
    end
    cookies.delete(:ead_code_metrics)
  end

  def payment_json
    @payment.as_json(only: %i[id code status amount method created_at])
  end

  def clear_cart_cookie
    cookies.delete("ead_#{@site}_cart_user")
  end

  def notify_purchase_cancelled_if_configured
    rule = WhatsappSendRule.first
    return unless rule&.purchase_cancelled_status

    user = User.find_by(id: payment_user_id)
    WhatsappMessage.send_text(user, "purchase_cancelled_status") if user.present?
  end

  def cart
    Cart.new(cookies_course)
  end

  def cookies_course
    @cookies_course ||= JSON.parse(cookies["ead_#{@site}_cart_user"]) rescue []
  end

  def set_cookies_cart
    courses = cookies_course
    courses << { "id" => @course.id, "local" => "", "discount" => "", "code" => 0 }
    courses = courses.uniq { |item| item["id"] }
    cookies["ead_#{@site}_cart_user"] = { value: courses.to_json, expires: 1.year.from_now, httponly: true }
  end

  def user_params
    params.require(:user).permit(:name, :email, :cpf, :phone, :birth_date)
  end

  def address_params
    params.require(:address).permit(:posta_code, :street, :number, :neighborhood, :city, :uf)
  end
end