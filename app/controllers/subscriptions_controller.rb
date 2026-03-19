class SubscriptionsController < ApplicationController
  before_action :set_course, only: [:new, :create]
  before_action :set_subscription, only: [:show, :thanks]
  skip_before_action :verify_authenticity_token, only: [:create, :status_webhook]

  def thanks
    @user = @subscription.user
  end

  def show
    render json: @subscription.to_json, status: :ok
  end

  def new
    @user = User.find(cookies[:payment_user]) rescue nil if cookies[:payment_user].present?
  end

  def create
    user = User.find(params[:user_id])
    price = @course.total_amount_with_installment
    amount = (price * 100).to_i
    courses = [{ "id" => @course.id }]

    subscription = Subscription.call!(company, courses, user, amount, subscription_params)

    redirect_to "/subscriptions/thanks/#{subscription.code}"
  rescue StandardError
    WhatsappMessage.send_text(user, "purchase_cancelled_status") if WhatsappSendRule.first.purchase_cancelled_status
    flash[:error] = "Tivemos um problema com seus dados. Por favor, clique no botão do WhatsApp para que possamos te ajudar."
    redirect_to "/subscriptions/new?course=#{params[:course]}"
  end

  def status_webhook
    if Subscription.status_webhook(params['data'])
      render json: {}, status: :ok
      return
    end

    render json: {}, status: :not_found
  rescue Exception => e
    Rails.logger.info "Erro ao fechar assinatura: #{params.inspect} - #{e.message} - #{e.backtrace}"
    render json: {}, status: :unauthorized
  end

  private

  def set_subscription
    @subscription = Subscription.find_by(code: params[:code])
  end

  def set_course
    @course = Course.find_by(slug: params[:course])
  end

  def subscription_params
    params.permit(:method, :token, :installments, :credit_card)
  end
end
