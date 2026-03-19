class Export::Csv::SubscriptionService
  def self.call(filename, subscription_ids, company)
    require 'csv'

    attributes_traduction = %w[Código Aluno Email Telefone Cursos Data_Compra Método Valor Status Parcelas]
    attributes = %w[code user_name user_email user_phone course_title created_at method_pt amount status_pt installments]
    subscriptions = Subscription.where(id: subscription_ids).order(created_at: :desc)

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        subscriptions.each do |subscription|
          csv << attributes.map do |attr|
            case attr
            when "user_name"
              subscription.user.name
            when "user_email"
              subscription.user.email
            when "user_phone"
              subscription.user.phone
            when "course_title"
              subscription.user_courses.titles
            when "created_at"
              subscription.created_at.strftime("%d/%m/%Y")
            when "amount"
              amount = subscription.amount / 100
              "R$ #{format('%.2f', amount).tr('.', ',')}"
            else
              subscription.send(attr)
            end
          end
        end
      end
    end

    Report.create(company: company, name: filename, file: AwsService.upload(tempfile.path, filename))
  end
end
