class Export::Xlsx::OrderGeneralService
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
    worksheet.write(0, 7, "Método", format)
    worksheet.write(0, 8, "Parcela", format)

    worksheet.write(0, 9, "Subtotal", format)
    worksheet.write(0, 10, "Desconto", format)
    worksheet.write(0, 11, "Valor Total", format)

    worksheet.write(0, 12, "Status", format)
    worksheet.write(0, 13, "Próxima Parcela", format)
    worksheet.write(0, 14, "Número Parcela Paga", format)
    worksheet.write(0, 15, "Primeira Parcela", format)
    worksheet.write(0, 16, "Valor Parcela", format)

    worksheet.write(0, 17, "Total", format)
    worksheet.write(0, 18, "Taxa", format)
    worksheet.write(0, 19, "Total Pagamento", format)

    worksheet.write(0, 20, "Observação", format)

    i = 1
    orders.each do |order|
      next_payment = order.order_installments.where(payment: nil).order(marker: :asc).first.date_generate_payment.strftime("%d/%m/%Y %H:%M") rescue ""
      next_payment = "" if order.status == "Cancelado"

      first_installment = order.invalid_first_installment_amount? ? order.amount_per_installment : order.first_installment_amount
      first_installment_amount = "R$ #{format('%.2f', first_installment).tr('.', ',')}"

      subtotal = format('%.2f', order.subtotal).tr('.', ',')
      discount = format('%.2f', order.discount).tr('.', ',')
      total_amount_without_interest = format('%.2f', order.total_amount_without_interest).tr('.', ',')

      course_titles = order.courses.map(&:title).join(" / ")
      amount_per_installment = format('%.2f', order.amount_per_installment).tr('.', ',')

      value_tax = format('%.2f', (order.amount - order.total_amount_without_interest)).tr('.', ',')
      amount = format('%.2f', order.amount).tr('.', ',')

      worksheet.write(i, 0, order.code)
      worksheet.write(i, 1, order.manager.name)
      worksheet.write(i, 2, order.user.name)
      worksheet.write(i, 3, order.user.email)
      worksheet.write(i, 4, order.user.cpf)
      worksheet.write(i, 5, course_titles)
      worksheet.write(i, 6, order.created_at.strftime("%d/%m/%Y %H:%M"))
      worksheet.write(i, 7, order.payment_method_pt)
      worksheet.write(i, 8, order.payment_installments)

      worksheet.write(i, 9, "R$ #{subtotal}")
      worksheet.write(i, 10, "R$ #{discount}")
      worksheet.write(i, 11, "R$ #{total_amount_without_interest}")

      worksheet.write(i, 12, order.status)
      worksheet.write(i, 13, next_payment)
      worksheet.write(i, 14, order.paid_installments)
      worksheet.write(i, 15, first_installment_amount)
      worksheet.write(i, 16, "R$ #{amount_per_installment}")

      worksheet.write(i, 17, "R$ #{total_amount_without_interest}", format)
      worksheet.write(i, 18, "R$ #{value_tax}", format)
      worksheet.write(i, 19, "R$ #{amount}", format)

      worksheet.write(i, 20, order.observation)
      i += 1
    end

    workbook.close

    Report.create(company:, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
