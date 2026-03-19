class Export::Xlsx::PaymentService
  def self.call(filename, payment_ids, company)
    require 'write_xlsx'

    payments = Payment.where(id: payment_ids).order(created_at: :desc)

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Código", format)
    worksheet.write(0, 1, "Aluno", format)
    worksheet.write(0, 2, "Email", format)
    worksheet.write(0, 3, "Telefone", format)
    worksheet.write(0, 4, "Curso", format)
    worksheet.write(0, 5, "Data da Compra", format)
    worksheet.write(0, 6, "Vencimento do Acesso", format)
    worksheet.write(0, 7, "Método", format)
    worksheet.write(0, 8, "Parcelas", format)
    worksheet.write(0, 9, "Valor Original", format)
    worksheet.write(0, 10, "Valor de Venda", format)
    worksheet.write(0, 11, "Desconto", format)
    worksheet.write(0, 12, "Valor Total", format)
    worksheet.write(0, 13, "Cupom de Desconto", format)
    worksheet.write(0, 14, "Status", format)
    worksheet.write(0, 15, "Tipo", format)
    worksheet.write(0, 16, "Atendimento", format)
    worksheet.write(0, 17, "Parcela do Pedido", format)
    worksheet.write(0, 18, "Total", format)
    worksheet.write(0, 19, "Taxa", format)
    worksheet.write(0, 20, "Total Pagamento", format)

    i = 1
    payments.each do |payment|
      user_courses = payment.user_courses.non_nil_amount
      payment_amount = (payment.amount / 100)
      courses_amount = user_courses.sum(:amount)

      payment_amount_pt = format('%.2f', payment_amount).tr('.', ',')
      courses_amount_pt = format('%.2f', courses_amount).tr('.', ',')
      value_tax = format('%.2f', payment.value_tax).tr('.', ',')

      user_courses.each do |user_course|
        access_until = user_course.access_until.strftime("%d/%m/%Y") rescue "Vitalício"
        value_of = "R$ #{user_course.course.value_of}"

        value_cash = format('%.2f', user_course.value_cash_course).tr('.', ',')
        value_with_discount = format('%.2f', user_course.value_with_discount).tr('.', ',')
        amount = format('%.2f', user_course.amount).tr('.', ',')

        worksheet.write(i, 0, payment.code)
        worksheet.write(i, 1, user_course.user.name)
        worksheet.write(i, 2, user_course.user.email)
        worksheet.write(i, 3, user_course.user.phone)
        worksheet.write(i, 4, user_course.course.title)
        worksheet.write(i, 5, payment.created_at.strftime("%d/%m/%Y"))
        worksheet.write(i, 6, access_until)
        worksheet.write(i, 7, payment.method_pt)
        worksheet.write(i, 8, payment.installments)
        worksheet.write(i, 9, value_of)
        worksheet.write(i, 10, "R$ #{value_cash}")
        worksheet.write(i, 11, "R$ #{value_with_discount}")
        worksheet.write(i, 12, "R$ #{amount}")
        worksheet.write(i, 13, user_course.discount)
        worksheet.write(i, 14, payment.status_pt)
        worksheet.write(i, 15, payment.location_genereted.to_s)
        worksheet.write(i, 16, payment.attendent_order)
        worksheet.write(i, 17, payment.number_installment_in_order)

        if payment.location_genereted != "Pedido" && payment.method_pt != "Bônus"
          worksheet.write(i, 18, "R$ #{courses_amount_pt}", format)
          worksheet.write(i, 19, "R$ #{value_tax}", format)
          worksheet.write(i, 20, "R$ #{payment_amount_pt}", format)
        end

        i += 1
      end
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
