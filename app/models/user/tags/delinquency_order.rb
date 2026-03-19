class User::Tags::DelinquencyOrder
  attr_accessor :order, :order_installment, :user

  def initialize(order_installment)
    @user = order_installment.order.user
    @order = order_installment.order
    @order_installment = order_installment
  end

  def call!
    order.courses do |course|
      UserTag.find_or_create_by(user: user, tag: course.tag) if course.tag_id.present?
    end

    case order.payment_method
    when "billet"
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "Inadimplente-Boleto"))
    when "pix"
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "Inadimplente-PIX"))
    end
  end
end
