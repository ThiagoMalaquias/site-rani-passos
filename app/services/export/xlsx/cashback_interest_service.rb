class Export::Xlsx::CashbackInterestService
  def self.call(filename, user_ids, company)
    require 'write_xlsx'

    users = User.where(id: user_ids)
      .joins(:cashback_interests)
      .select("users.*, MAX(cashback_interests.created_at) AS last_interest_at")
      .group("users.id")
      .order("last_interest_at DESC")

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Nome", format)
    worksheet.write(0, 1, "Email", format)
    worksheet.write(0, 2, "Cursos", format)
    worksheet.write(0, 3, "Saldo de Cashback", format)
    worksheet.write(0, 4, "Último Interesse", format)

    i = 1
    users.each do |user|
      cashback_balance = (user.cashback_balance_cents / 100)
      cashback_balance_pt = format('%.2f', cashback_balance).tr('.', ',')

      worksheet.write(i, 0, user.name)
      worksheet.write(i, 1, user.email)
      worksheet.write(i, 2, user.cashback_interests.map(&:course).map(&:title).join(", "))
      worksheet.write(i, 3, "R$ #{cashback_balance_pt}")
      worksheet.write(i, 4, user.last_interest_at.strftime("%d/%m/%Y %H:%M"))
      i += 1
    end
    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
