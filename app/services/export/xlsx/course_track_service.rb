class Export::Xlsx::CourseTrackService
  def self.call(filename, user_ids, course, company)
    require 'write_xlsx'

    users = User.joins(:tracks).where(users: { id: user_ids })
                .select("users.*, MAX(user_tracks.created_at - INTERVAL '3 hours') as last_track_date")
                .group('users.id')
                .order('last_track_date DESC')

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Nome", format)
    worksheet.write(0, 1, "Email", format)
    worksheet.write(0, 2, "Telefone", format)
    worksheet.write(0, 3, "Ultima Abertura", format)
    worksheet.write(0, 4, "Curso", format)

    i = 1
    users.each do |user|
      courses = user.cart_course_names

      worksheet.write(i, 0, user.name)
      worksheet.write(i, 1, user.email)
      worksheet.write(i, 2, user.phone)
      worksheet.write(i, 3, user.last_track_date.strftime("%d/%m/%Y %H:%M"))
      worksheet.write(i, 4, course.title)
      i += 1
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end
