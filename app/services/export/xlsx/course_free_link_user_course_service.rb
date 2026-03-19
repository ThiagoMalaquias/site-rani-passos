class Export::Xlsx::CourseFreeLinkUserCourseService
  def self.call(filename, free_link_user_course_ids, company)
    require 'write_xlsx'

    free_link_user_courses = FreeLinkUserCourse.where(id: free_link_user_course_ids)

    workbook = WriteXLSX.new("/tmp/#{filename}")
    worksheet = workbook.add_worksheet

    format = workbook.add_format
    format.set_bold

    worksheet.write(0, 0, "Nome", format)
    worksheet.write(0, 1, "Email", format)
    worksheet.write(0, 2, "Telefone", format)
    worksheet.write(0, 3, "CPF", format)
    worksheet.write(0, 4, "Inicio", format)
    worksheet.write(0, 5, "Curso", format)

    i = 1
    free_link_user_courses.each do |free_link_user_course|
      user = free_link_user_course.user_course.user

      worksheet.write(i, 0, user.name)
      worksheet.write(i, 1, user.email)
      worksheet.write(i, 2, user.phone)
      worksheet.write(i, 3, user.cpf)
      worksheet.write(i, 4, free_link_user_course.user_course.access_start.strftime("%d/%m/%Y"))
      worksheet.write(i, 5, free_link_user_course.user_course.course.title)
      i += 1
    end

    workbook.close

    Report.create(company: company, name: filename, file: AwsService.upload("/tmp/#{filename}", filename))
  end
end