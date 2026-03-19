class Cart
  INTEREST = 1.67

  def initialize(cookies)
    @cookies = cookies
  end

  def courses
    Course.find(@cookies.pluck("id"))
  end

  def max_installments
    courses.map(&:installments).map(&:to_i).max { |a, b| a <=> b }
  end

  def total_amount
    @cookies.sum do |course_in_cookie|
      course = Course.find(course_in_cookie["id"])
      course.total_price(course_in_cookie)
    end
  end

  def total_amount_with_installment(total_with_cashback, installment = "")
    if installment.present?
      value_installment = all_installments(total_with_cashback).find { |i| i[:key] == installment.to_i }[:value]
      value = value_installment * installment.to_i
      return format('%.2f', value).to_f
    end

    total_with_cashback
  end

  def all_installments(total_with_cashback = nil)
    total_cash = total_with_cashback.presence || total_amount

    (1..max_installments.to_i).map do |installment|
      if installment == 1
        { key: 1, value: value_unic(total_cash) }
      elsif installment >= 2 && installment <= 6
        unic = total_cash / installment
        { key: installment, value: value_unic(unic) }
      else
        interest_real = total_cash * INTEREST / 100
        calc_installments(total_cash, interest_real, installment)
      end
    end
  end

  def check_discount
    cookies_course = @cookies.dup
    return nil if cookies_course.blank?

    cookies_course.shift
    courses_with_cart = cookies_course.select { |course| course["local"] == "cart" && course["discount"].present? }
    cart_discounts = CartDiscount.actives.order(title: :asc)
    cart_discounts[courses_with_cart.count] rescue nil
  end

  def validating_course_discounts
    cookies_course = @cookies.dup
    cart_discount_ids = CartDiscount.actives.pluck(:id)
    return cookies_course if cart_discount_ids.blank? || cookies_course.blank?

    courses_without_first = cookies_course.shift
    if courses_without_first["code"].to_i.positive?
      courses_without_first["code"] = 0
      courses_without_first["discount"] = ""
    end

    cookies_course.unshift(courses_without_first)
    filtered_codes = cookies_course.filter_map { |cc| cc["code"].to_i }.reject(&:zero?)

    if cart_discount_ids != filtered_codes
      cart_discount_ids.each_with_index do |id, index|
        code = filtered_codes[index]
        next if code.nil?

        cookies_course = cookies_course.map do |obj|
          if obj["code"].to_i == code
            cart_discount = CartDiscount.actives.find(id)
            obj["code"] = id
            obj["discount"] = cart_discount.title
          end
          obj
        end
      end
    end

    cookies_course
  end

  private

  def calc_installments(cash, interest_real, installment)
    unic = (cash / installment) + interest_real
    { key: installment, value: value_unic(unic) }
  end

  def value_unic(unic)
    unic
  end
end
