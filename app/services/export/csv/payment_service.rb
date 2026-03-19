class Export::Csv::PaymentService
  def self.call(filename, payment_ids, company)
    require 'csv'

    attributes_traduction = %w[Código Aluno Email Telefone Cursos Data_Compra Método Valor Status Desconto Parcelas]
    attributes = %w[code user_name user_email user_phone course_title created_at method_pt amount status_pt discount installments]
    payments = Payment.where(id: payment_ids).order(created_at: :desc)

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        payments.each do |payment|
          csv << attributes.map do |attr|
            case attr
            when "user_name"
              payment.user.name
            when "user_email"
              payment.user.email
            when "user_phone"
              payment.user.phone
            when "course_title"
              payment.user_courses.titles
            when "created_at"
              payment.created_at.strftime("%d/%m/%Y")
            when "amount"
              amount = payment.amount / 100
              "R$ #{format('%.2f', amount).tr('.', ',')}"
            when "discount"
              payment.user_courses.discounts
            else
              payment.send(attr)
            end
          end
        end
      end
    end

    Report.create(company: company, name: filename, file: AwsService.upload(tempfile.path, filename))
  end
end
