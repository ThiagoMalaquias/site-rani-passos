class Export::Csv::CourseTrackService
  def self.call(filename, user_ids, course, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Telefone Ultima_Abertura Curso]
    attributes = %w[name email phone last_track_date course]
    users = User.joins(:tracks).where(users: { id: user_ids })
                .select("users.*, MAX(user_tracks.created_at - INTERVAL '3 hours') as last_track_date")
                .group('users.id')
                .order('last_track_date DESC')

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        users.each do |user|
          csv << attributes.map do |attr|
            case attr
            when "last_track_date"
              user.last_track_date.strftime("%d/%m/%Y %H:%M")
            when "course"
              course.title
            else
              user.send(attr)
            end
          end
        end
      end
    end

    Report.create(company: company, name: filename, file: AwsService.upload(tempfile.path, filename))
  end
end
