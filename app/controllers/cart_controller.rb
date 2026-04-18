class CartController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:apply_discount]
  before_action :clear_cart, only: [:new]

  def apply_discount
    if params[:discount].blank?
      redirect_to cart_index_path
      return
    end

    course = Course.find(params[:course_id])
    value = course.percentage_discount_applied({ "discount" => params[:discount], "code" => 0 })
    if value == -1
      flash[:error] = "Nenhum desconto encontrado"
      redirect_to cart_index_path
      return
    end

    courses = cookies_course
    courses = courses.map! do |obj|
      obj["discount"] = params[:discount] if obj["id"] == course.id
      obj
    end

    redirect_cart(courses, message: "Desconto aplicado.")
  end

  def new
    course = Course.find_by(slug: params[:course])
    courses = cookies_course
    cart_discount = cart.check_discount

    local = params[:local] || "courses"
    discount = params[:discount] || ""
    code = params[:code] || 0

    if local != "courses"
      if discount.present? && cart_discount.present? && discount != cart_discount.title
        discount = cart_discount.title
      elsif discount.present? && cart_discount.blank?
        discount = ""
      end
    end

    courses << { "id" => course.id, "local" => local, "discount" => discount, "code" => code }
    courses = courses.uniq { |item| item["id"] }
    set_cookies(courses)

    cookies[:user_name] = params[:user_name]
    cookies[:user_email] = params[:user_email]
    cookies[:user_phone] = params[:user_phone]

    redirect_to new_payment_path
    return
  end

  def destroy
    courses = cookies_course
    courses.delete_if { |obj| obj["id"] == params[:id].to_i }
    courses = Cart.new(courses).validating_course_discounts

    redirect_cart(courses, message: "Curso excluído com sucesso.")
  rescue Exception => e
    flash[:error] = e
    redirect_to cart_index_path
  end

  def clear_courses
    cookies["ead_#{@site}_cart_user"] = nil
    redirect_to cart_index_path
  end

  def clear_cart
    cookies["ead_#{@site}_cart_user"] = nil if params[:clear_cart] == "true" || params[:user_name].present?
  end

  def all_installments
    installments = cart.all_installments(params[:total_with_cashback].to_f)
    render json: { installments: installments }, status: :ok
  end

  private

  def cookies_course
    @cookies_course ||= JSON.parse(cookies["ead_#{@site}_cart_user"]) rescue []
  end

  def cart
    Cart.new(cookies_course)
  end

  def set_cookies(courses)
    cookies["ead_#{@site}_cart_user"] = { value: courses.to_json, expires: 1.year.from_now, httponly: true }
  end

  def redirect_cart(courses, message:)
    set_cookies(courses)
    flash[:notice] = message
    redirect_to cart_index_path
  end
end
