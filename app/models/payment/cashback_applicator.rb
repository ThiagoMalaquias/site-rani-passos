class Payment::CashbackApplicator
  def initialize(user:, courses:)
    @user = user
    @courses = courses
  end

  def applicable?
    @user.cashback_balance_cents.positive? && Payment.permit_courses_cashback(@courses)
  end

  def amount_to_apply
    return 0 unless applicable?

    @user.cashback_balance_cents / 100.0
  end
end