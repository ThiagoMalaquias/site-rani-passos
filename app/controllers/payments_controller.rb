class PaymentsController < ApplicationController
  before_action :require_cart_cookies, only: [:new, :create]
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

  def cashback_interest
    result = Payment::CashbackInterestService.new(
      user_id: params[:user_id],
      authentication_token: params[:authentication_token],
      course_id: params[:course_id],
      cookies_course: cookies_course,
      site: @site
    ).call
  
    unless result.success?
      redirect_to root_path, notice: result.error_message
      return
    end
  
    cookies[:payment_user] = result.payment_user_id
    cookies[:cashback_applied] = result.cashback_applied
    cookies["ead_#{@site}_cart_user"] = {
      value: result.cart_courses.to_json,
      expires: 1.year.from_now,
      httponly: true
    }
  
    redirect_to new_payment_path, notice: result.notice
  end

  def new
    @courses = cart.courses
    @total_amount = cart.total_amount
    @all_installments = cart.all_installments

    return if payment_user_id.blank?
    @user = User.find_by(id: payment_user_id)

    cashback_applicator = Payment::CashbackApplicator.new(user: @user, courses: @courses)
    @applied_cashback = cookies[:cashback_applied].present? && cashback_applicator.applicable?
  
    if @applied_cashback
      cashback_value = cashback_applicator.amount_to_apply
      @total_amount = cart.total_amount - cashback_value
      @all_installments = cart.all_installments(@total_amount)
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

  def require_cart_cookies
    return if cookies["ead_#{@site}_cart_user"].present?

    redirect_to cart_index_path
  end

  def set_payment
    @payment = Payment.find_by(code: params[:code])
  end

  def payment_user_id
    cookies[:payment_user].presence
  end

  def payment_params
    params.permit(:method, :token, :installments, :credit_card)
  end

  def utm_cookies
    {
      utm_source: cookies[:utm_source],
      utm_medium: cookies[:utm_medium],
      utm_campaign: cookies[:utm_campaign]
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
end