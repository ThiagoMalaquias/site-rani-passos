module CoursesHelper
  def sidebar_price(course, discount)
    return recurrent_price(course) if course.recurrent
    return standard_price(course) if discount.nil?

    discounted_price(course, discount)
  end

  private

  def recurrent_price(course)
    "
      <span class='oldprice'>de #{number_to_currency(course.value_of)} por</span>
      <div class='price'>
        <h2>#{number_to_currency(course.value_cash)}</h2>
      </div>
      <p class='pricepoll'>Recorrente</p>
    "
  end

  def standard_price(course)
    "
      <span class='oldprice'>de #{number_to_currency(course.value_of)} por</span>
      <div class='price'>
        <span>#{course.installments}x </span>
        <h2>#{number_to_currency(course.last_installment)}</h2>
      </div>
      <p class='pricepoll'>ou #{number_to_currency(course.value_cash)} à vista</p>
    "
  end

  def discounted_price(course, discount)
    course_in_cookies = { "discount" => discount, "code" => 0 }
    total_price = course.total_price(course_in_cookies)

    course.value_cash = Convert.convert_comma_to_string(total_price)

    "
      <span class='oldprice'>de #{number_to_currency(course.value_of)} por</span>
      <div class='price'>
        <span>#{course.installments}x</span>
        <h2>#{number_to_currency(course.last_installment)}</h2>
      </div>
      <p class='pricepoll'>ou #{number_to_currency(total_price)} à vista</p>
      <p class='pricepoll'> desconto aplicado: <b>#{discount}</b></p>
    "
  end
end
