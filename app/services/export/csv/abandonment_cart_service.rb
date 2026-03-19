class Export::Csv::AbandonmentCartService
  def self.call(filename, user_ids, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Telefone CPF Ultima_Abertura Cursos]
    attributes = %w[name email phone cpf last_cart_date courses]
    users = User.joins(:open_carts).where(users: { id: user_ids })
                .select("users.*, MAX(user_open_carts.created_at - INTERVAL '3 hours') as last_cart_date")
                .group('users.id')
                .order('last_cart_date DESC')

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        users.each do |user|
          csv << attributes.map do |attr|
            case attr
            when "last_cart_date"
              user.last_cart_date.strftime("%d/%m/%Y %H:%M")
            when "courses"
              user.cart_course_names
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
