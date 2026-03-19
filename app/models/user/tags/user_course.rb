class User::Tags::UserCourse
  attr_accessor :user, :authenticate, :payment, :user, :course

  def initialize(user_course)
    @course = user_course.course
    @authenticate = user_course.authenticate
    @payment = user_course.payment
    @user = user_course.user
  end

  def call!
    UserTag.find_or_create_by(user: user, tag: course.tag) if course.tag_id.present?

    if course.nature == 'free'
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: "curso.gratuito"))
      return
    end

    refresh_payment_tags
  end

  private

  def refresh_payment_tags
    return if payment.blank?

    status = payment.status
    order_installment = OrderInstallment.find_by(payment: payment)

    if order_installment.present?
      order = order_installment.order
      payment_method = "order_#{order.payment_method}"
      payment_method = "order_recorrente" if order.payment_installments == "recorrente"
    else
      payment_method = payment.method
    end

    if (tags_to_create = payment_status_tags[status])
      tag_name = tags_to_create[payment_method] || tags_to_create['all']
      UserTag.find_or_create_by(user: user, tag: Tag.find_by(name: tag_name))
    end

    tags_to_destroy = payment_status_tags.keys - [status]
    tags_to_destroy.each do |status_to_destroy|
      tag_name = payment_status_tags[status_to_destroy][payment_method] || payment_status_tags[status_to_destroy]['all']
      user_tag = UserTag.find_by(user: user, tag: Tag.find_by(name: tag_name))
      user_tag&.destroy
    end
  end

  def payment_status_tags
    {
      'paid' => {
        'card' => 'Pago-Cartão',
        'billet' => 'Pago-Boleto',
        'pix' => 'Pago-PIX',
        'bonus' => 'Pago-Bônus',
        'order_card' => 'Pago-Pedido-Cartão',
        'order_billet' => 'Pago-Pedido-Boleto',
        'order_pix' => 'Pago-Pedido-Pix',
        'order_recurrent' => 'Pago-Pedido-Recorrente'
      },
      'pending' => {
        'billet' => 'PagamentoPendente-Boleto',
        'pix' => 'PagamentoPendente-PIX'
      },
      'canceled' => {
        'all' => 'Pagamento-Cancelado'
      },
      'refunded' => {
        'card' => 'Reembolsado-Cartão',
        'billet' => 'Reembolsado-Boleto',
        'pix' => 'Reembolsado-PIX'
      }
    }
  end
end
