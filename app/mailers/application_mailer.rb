class ApplicationMailer < ActionMailer::Base
  default from: "#{Teacher.first.name} <contato@ranipassos.com.br>"
  layout 'mailer'
end
