class Export::Csv::OrderService
  def self.call(filename, order_ids, company)
    require 'csv'

    attributes_traduction = %w[Código Criador Nome Email CPF Cursos Data_Pedido Data_Pagamento Valor Status Parcelas Primeira_Parcela Valor_Parcela Proxima_Parcela Metodo Observacao]
    attributes = %w[code manager user_name user_email user_cpf course_title created_at created_payment amount status payment_installments first_installment_amount amount_per_installment next_installment payment_method_pt observation]
    orders = Order.where(id: order_ids).order(created_at: :desc)

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        orders.each do |order|
          csv << attributes.map do |attr|
            case attr
            when "manager"
              order.manager.name
            when "user_name"
              order.user.name
            when "user_email"
              order.user.email
            when "user_cpf"
              order.user.cpf
            when "course_title"
              order.courses.map(&:title).join(', ')
            when "created_at"
              order.created_at.strftime("%d/%m/%Y")
            when "created_payment"
              order.order_installments.where.not(payment: nil).order(marker: :asc).last.payment.updated_at.strftime("%d/%m/%Y %H:%M") rescue ""
            when "amount"
              "R$ #{format('%.2f', order.amount).tr('.', ',')}"
            when "next_installment"
              next_payment = order.order_installments.where(payment: nil).order(marker: :asc).first.date_generate_payment.strftime("%d/%m/%Y %H:%M") rescue ""
              next_payment = "" if order.status == "Cancelado"
              next_payment
            when "first_installment_amount"
              first_installment = order.invalid_first_installment_amount? ? order.amount_per_installment : order.first_installment_amount
              "R$ #{format('%.2f', first_installment).tr('.', ',')}"
            when "amount_per_installment"
              "R$ #{format('%.2f', order.amount_per_installment).tr('.', ',')}"
            else
              order.send(attr)
            end
          end
        end
      end
    end

    Report.create(company: company, name: filename, file: AwsService.upload(tempfile.path, filename))
  end
end
