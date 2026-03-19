class ReportPayment
  attr_reader :course_id, :start_date, :end_date

  def initialize(params)
    @course_id = params[:course_id]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
  end

  def dashboard_graphic
    dates = days_payments_graphic
    dates.map do |date|
      payments_total = paid_payments_total_on_date(date)
      {
        date: date.to_date.strftime("%d/%m").to_s,
        amount: payments_total.sum(:amount) / 100
      }
    end
  end

  def with_credit_card
    data_methods(payments.period_date(start_date, end_date).paids.method_card)
  end

  def with_billet
    data_methods(payments.period_date(start_date, end_date).paids.method_billet)
  end

  def with_pix
    data_methods(payments.period_date(start_date, end_date).paids.method_pix)
  end

  def with_bonus
    data_methods(payments.period_date(start_date, end_date).paids.method_bonus)
  end

  def all_refunded
    data_methods(payments.period_date(start_date, end_date).refundeds)
  end

  def all_canceled
    data_methods(payments.period_date(start_date, end_date).canceleds)
  end

  def unpaid_billet
    data_methods(payments.period_date(start_date, end_date).pendings.method_billet)
  end

  def best_selling_courses
    payments
      .select("user_courses.course_id, courses.title as course_name, count(user_courses.course_id) as total")
      .joins(user_courses: :course)
      .paids
      .period_date(start_date, end_date)
      .group('user_courses.course_id, course_name')
      .order(total: :desc)
      .limit(10)
  end

  private

  def payments
    return Payment.all if course_id.nil? || course_id.blank?

    Payment
      .joins(:user_courses)
      .where(user_courses: { course_id: course_id })
      .distinct
  end

  def data_methods(result)
    { amount: result.sum(:amount), quantity: result.count }
  end

  def paid_payments_total_on_date(date)
    payments.paids.period_date(date, date)
  end

  def days_payments_graphic
    days = [start_date]

    (end_date.to_date - start_date.to_date).to_i.times.map do |index|
      (end_date.to_date - index.days).strftime("%Y-%m-%d")
    end.reverse_each { |date| days << date }

    days
  end
end
