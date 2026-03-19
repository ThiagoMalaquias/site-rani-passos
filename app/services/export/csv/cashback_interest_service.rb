class Export::Csv::CashbackInterestService
  def self.call(filename, user_ids, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Cursos Saldo_de_Cashback Último_Interesse]
    attributes = %w[name email courses cashback_balance_pt last_interest_at]

    users = User.where(id: user_ids)
      .joins(:cashback_interests)
      .select("users.*, MAX(cashback_interests.created_at) AS last_interest_at")
      .group("users.id")
      .order("last_interest_at DESC")

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        users.each do |user|
          csv << attributes.map do |attr|
            case attr
            when "courses"
              user.cashback_interests.map(&:course).map(&:title).join(", ")
            when "last_interest_at"
              user.last_interest_at.strftime("%d/%m/%Y %H:%M")
            when "cashback_balance_pt"
              "R$ #{format('%.2f', user.cashback_balance_cents / 100).tr('.', ',')}"
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
