class Export::Csv::UserTagsService
  def self.call(filename, user_ids, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Telefone CPF Criação Etiquetas]
    attributes = %w[name email phone cpf created_at tags]
    users = User.where(id: user_ids).order(created_at: :desc)

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        users.each do |user|
          csv << attributes.map do |attr|
            case attr
            when "created_at"
              user.created_at.strftime("%d/%m/%Y %H:%M")
            when "tags"
              user.user_tags.map(&:tag).map(&:name).join(', ')
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
