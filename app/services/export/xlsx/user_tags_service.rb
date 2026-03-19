class Export::Xlsx::UserTagsService
  def self.call(filename, user_ids, company)
    require 'write_xlsx'

    users = User.where(id: user_ids).order(created_at: :desc)

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Nome", format)
    worksheet.write(0, 1, "Email", format)
    worksheet.write(0, 2, "Telefone", format)
    worksheet.write(0, 3, "CPF", format)
    worksheet.write(0, 4, "Criação", format)
    worksheet.write(0, 5, "Etiquetas", format)

    i = 1
    users.each do |user|
      tags = user.user_tags.map(&:tag).map(&:name).join(', ')

      worksheet.write(i, 0, user.name)
      worksheet.write(i, 1, user.email)
      worksheet.write(i, 2, user.phone)
      worksheet.write(i, 3, user.cpf)
      worksheet.write(i, 4, user.created_at.strftime("%d/%m/%Y %H:%M"))
      worksheet.write(i, 5, tags)
      i += 1
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
