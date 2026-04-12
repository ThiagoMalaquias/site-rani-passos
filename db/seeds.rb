Company.create(name: 'Ead Technology')
Teacher.create(company: Company.first)
WhatsappSendRule.create(company: Company.first)
Manager.create(company: Company.first, email: 'ranielison@gmail.com', password: "ead@1234")