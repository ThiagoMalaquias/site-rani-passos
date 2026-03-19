class Export::Csv::UserService
  def self.call(filename, user_ids, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Telefone CPF Status Criação Cursos Endereço]
    attributes = %w[name email phone cpf status created_at courses address]
    users = User.where(id: user_ids).order(name: :asc)

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        users.each do |user|
          csv << attributes.map do |attr|
            case attr
            when "created_at"
              user.created_at.strftime("%d/%m/%Y %H:%M")
            when "courses"
              user.courses.map(&:title).join(', ')
            when "address"
              address = user.addresses.last
              format_address = "#{address.street}, #{address.number} - #{address.neighborhood}. #{address.city} - #{address.uf}" if address.present?
              format_address
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
