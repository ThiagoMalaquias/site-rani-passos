class Export::Csv::CourseFreeLinkUserCourseService
  def self.call(filename, free_link_user_course_ids, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Telefone CPF Inicio Curso]
    attributes = %w[name email phone cpf access_start course_title]
    
    free_link_user_courses = FreeLinkUserCourse.where(id: free_link_user_course_ids)

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        free_link_user_courses.each do |free_link_user_course|
          csv << attributes.map do |attr|
            case attr
            when "name"
              free_link_user_course.user_course.user.name
            when "email"
              free_link_user_course.user_course.user.email
            when "phone"
              free_link_user_course.user_course.user.phone
            when "cpf"
              free_link_user_course.user_course.user.cpf
            when "access_start"
              free_link_user_course.user_course.access_start.strftime("%d/%m/%Y")
            when "course_title"
              free_link_user_course.user_course.course.title
            end
          end
        end
      end
    end

    Report.create(company: company, name: filename, file: AwsService.upload(tempfile.path, filename))
  end
end
