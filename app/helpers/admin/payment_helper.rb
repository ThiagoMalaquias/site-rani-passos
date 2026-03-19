module Admin::PaymentHelper
  def color_status(status)
    case status
    when 'pending'
      return 'secondary'
    when 'paid'
      return "success"
    when 'canceled'
      return "danger"
    when 'expired'
      return "warning"
    when 'refunded'
      return "dark"
    when 'failed'
      return "danger"
    end
  end

  def render_payment_courses(payment, max: 3)
    user_courses = payment.user_courses.non_nil_amount
    displayed_courses = user_courses.first(max)
    remaining = user_courses.size - max

    html = displayed_courses.map do |user_course|
      link_to(
        user_course.course.title.truncate(20),
        "#{admin_course_path(user_course.course)}?local=payments",
        data: { toggle: "tooltip", placement: "top" },
        title: user_course.course.title,
        class: "link-default"
      )
    end.join("<br>").html_safe

    if remaining.positive?
      html += tag.br
      html += link_to(
        "+#{remaining} outro#{'s' if remaining > 1} curso#{'s' if remaining > 1}",
        admin_payment_path(payment),
        class: "link-default text-sm text-muted"
      )
    end

    html
  end
end
