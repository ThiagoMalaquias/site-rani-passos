class Import::Xlsx::CampaignUsersService 
  attr_accessor :arquivo, :campaign

  def initialize(arquivo, campaign)
    @arquivo = arquivo
    @campaign = campaign
  end

  def call!
    workbook = SimpleXlsxReader.open(arquivo.tempfile)
    worksheets = workbook.sheets

    if worksheets.count < 1
      raise "Não foi encontrado registro no arquivo enviado"
    end

    worksheets.each do |worksheet|
      worksheet.rows.each do |line|
        importar_linha(line)
      end
    end
  end

  def importar_linha(linha)
    nome = 0
    email = 1

    return if linha[nome] == "Nome" || linha[nome].nil?

    user = @campaign.users.new
    user.name = linha[nome].to_s.strip if linha[nome].present?
    user.email = linha[email].to_s if linha[email].present?
    user.save!
  rescue Exception => e
    raise e
    Rails.logger.error e.message
  end
end