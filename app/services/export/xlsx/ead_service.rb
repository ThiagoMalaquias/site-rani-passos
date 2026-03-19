class Export::Xlsx::EadService
  def self.call(filename, leads, company)
    require 'write_xlsx'

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Nome", format)
    worksheet.write(0, 1, "Email", format)
    worksheet.write(0, 2, "Telefone", format)
    worksheet.write(0, 3, "Criação", format)

    i = 1
    leads.order(name: :asc).each do |lead|
      worksheet.write(i, 0, lead.name)
      worksheet.write(i, 1, lead.email)
      worksheet.write(i, 2, lead.phone)
      worksheet.write(i, 3, lead.created_at.strftime("%d/%m/%Y %H:%M"))
      i += 1
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
