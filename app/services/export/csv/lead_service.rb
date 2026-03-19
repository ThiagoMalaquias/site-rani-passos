class Export::Csv::LeadService
  def self.call(filename, leads, company)
    require 'csv'

    attributes_traduction = %w[Nome Email Telefone Criação]
    attributes = %w[name email phone created_at]

    tempfile = Tempfile.new([filename, '.csv']).tap do |file|
      CSV.open(file, 'wb') do |csv|
        csv << attributes_traduction

        leads.order(name: :asc).each do |lead|
          csv << attributes.map do |attr|
            case attr
            when "created_at"
              lead.created_at.strftime("%d/%m/%Y %H:%M")
            else
              lead.send(attr)
            end
          end
        end
      end
    end

    Report.create(company: company, name: filename, file: AwsService.upload(tempfile.path, filename))
  end
end
