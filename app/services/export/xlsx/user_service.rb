class Export::Xlsx::UserService
  def self.call(filename, user_ids, company)
    require 'write_xlsx'

    users = User.where(id: user_ids).order(name: :asc)

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Nome", format)
    worksheet.write(0, 1, "Email", format)
    worksheet.write(0, 2, "Telefone", format)
    worksheet.write(0, 3, "CPF", format)
    worksheet.write(0, 4, "Status", format)
    worksheet.write(0, 5, "Criação", format)
    worksheet.write(0, 6, "Cursos", format)
    worksheet.write(0, 7, "Endereço", format)

    i = 1
    users.each do |user|
      address = user.addresses.last
      courses = user.courses.map(&:title).join(', ')

      worksheet.write(i, 0, user.name)
      worksheet.write(i, 1, user.email)
      worksheet.write(i, 2, user.phone)
      worksheet.write(i, 3, user.cpf)
      worksheet.write(i, 4, user.status)
      worksheet.write(i, 5, user.created_at.strftime("%d/%m/%Y %H:%M"))
      worksheet.write(i, 6, courses)
      worksheet.write(i, 7, "#{address&.street}, #{address&.number} - #{address&.neighborhood}. #{address&.city} - #{address&.uf}") if address.present?
      i += 1
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
