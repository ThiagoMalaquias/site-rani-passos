class Export::Xlsx::OrderService
  def self.call(filename, order_ids, company)
    require 'write_xlsx'

    orders = Order.where(id: order_ids).order(created_at: :desc)

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Código", format)
    worksheet.write(0, 1, "Criador", format)
    worksheet.write(0, 2, "Nome", format)
    worksheet.write(0, 3, "Email", format)
    worksheet.write(0, 4, "CPF", format)
    worksheet.write(0, 5, "Curso", format)
    worksheet.write(0, 6, "Data do Pedido", format)
    worksheet.write(0, 7, "Data do Pagamento", format)
    worksheet.write(0, 8, "Preço do Curso Original", format)
    worksheet.write(0, 9, "Preço do Curso Venda", format)
    worksheet.write(0, 10, "Total Pagamento", format)
    worksheet.write(0, 11, "Status", format)
    worksheet.write(0, 12, "Parcelamento", format)
    worksheet.write(0, 13, "Proxima Parcela", format)
    worksheet.write(0, 14, "Número Parcela Paga", format)
    worksheet.write(0, 15, "Metodo de Pagamento", format)
    worksheet.write(0, 16, "Primeira Parcela", format)
    worksheet.write(0, 17, "Valor Parcela", format)
    worksheet.write(0, 18, "Observação", format)

    i = 1
    orders.each do |order|
      payment = order.order_installments.where.not(payment: nil).order(marker: :asc).last.payment.updated_at.strftime("%d/%m/%Y %H:%M") rescue ""

      next_payment = order.order_installments.where(payment: nil).order(marker: :asc).first.date_generate_payment.strftime("%d/%m/%Y %H:%M") rescue ""
      next_payment = "" if order.status == "Cancelado"

      valor = format('%.2f', order.amount).tr('.', ',')

      first_installment = order.invalid_first_installment_amount? ? order.amount_per_installment : order.first_installment_amount
      first_installment_amount = "R$ #{format('%.2f', first_installment).tr('.', ',')}"

      amount_per_installment = format('%.2f', order.amount_per_installment).tr('.', ',')

      order.order_courses.find_each do |order_course|
        value_course = order_course.course.value_of
        value_cash = order_course.value_cash

        worksheet.write(i, 0, order.code)
        worksheet.write(i, 1, order.manager.name)
        worksheet.write(i, 2, order.user.name)
        worksheet.write(i, 3, order.user.email)
        worksheet.write(i, 4, order.user.cpf)
        worksheet.write(i, 5, order_course.course.title)
        worksheet.write(i, 6, order.created_at.strftime("%d/%m/%Y %H:%M"))
        worksheet.write(i, 7, payment)
        worksheet.write(i, 8, "R$ #{value_course}")
        worksheet.write(i, 9, "R$ #{value_cash}")
        worksheet.write(i, 10, "R$ #{valor}")
        worksheet.write(i, 11, order.status)
        worksheet.write(i, 12, order.payment_installments)
        worksheet.write(i, 13, next_payment)
        worksheet.write(i, 14, order.paid_installments)
        worksheet.write(i, 15, order.payment_method_pt)
        worksheet.write(i, 16, first_installment_amount)
        worksheet.write(i, 17, "R$ #{amount_per_installment}")
        worksheet.write(i, 18, order.observation)
        i += 1
      end
    end

    workbook.close

    Report.create(company:, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
