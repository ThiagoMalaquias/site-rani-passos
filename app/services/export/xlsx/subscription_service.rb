class Export::Xlsx::SubscriptionService
  def self.call(filename, subscription_ids, company)
    require 'write_xlsx'

    subscriptions = Subscription.where(id: subscription_ids).order(created_at: :desc)

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
    worksheet.write(0, 6, "Método", format)
    worksheet.write(0, 7, "Valor", format)
    worksheet.write(0, 8, "Status", format)
    worksheet.write(0, 9, "Parcelas", format)

    i = 1
    subscriptions.each do |subscription|
      amount = subscription.amount / 100
      valor = format('%.2f', amount).tr('.', ',')

      worksheet.write(i, 0, subscription.code)
      worksheet.write(i, 1, subscription.user.name)
      worksheet.write(i, 2, subscription.user.email)
      worksheet.write(i, 3, subscription.user.phone)
      worksheet.write(i, 4, subscription.user_courses.titles)
      worksheet.write(i, 5, subscription.created_at.strftime("%d/%m/%Y"))
      worksheet.write(i, 6, subscription.method_pt)
      worksheet.write(i, 7, "R$ #{valor}")
      worksheet.write(i, 8, subscription.status_pt)
      worksheet.write(i, 9, subscription.installments)
      i += 1
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
