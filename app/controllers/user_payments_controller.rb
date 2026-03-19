class UserPaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def index
    @courses = cart.courses
    @total_amount = cart.total_amount

    @user = User.find(cookies[:payment_user]) rescue nil if cookies[:payment_user].present?
  end

  def create
    @user = User::Site::Create.new(company, user_params, address_params).call!

    unless @user.instance_of?(User)
      flash[:error] = @user[:message_error]
      redirect_to "/user_payments"
      return
    end

    @user.update(user_params.merge(last_ip: request.remote_ip, user_agent: request.user_agent))
    cookies[:payment_user] = @user.id.to_s

    cookies_course.each do |cc|
      course = Course.find(cc["id"])
      UserOpenCart.create(user: @user, course: course)
    end

    redirect_to "/payments/new"
    return
  end

  private

  def cart
    Cart.new(cookies_course)
  end

  def user_params
    params.require(:user).permit(:name, :email, :cpf, :phone)
  end

  def cookies_course
    JSON.parse(cookies["ead_#{@site}_cart_user"]) rescue []
  end

  def address_params
    params.require(:address).permit(:posta_code, :street, :number, :neighborhood, :city, :uf)
  end
end
