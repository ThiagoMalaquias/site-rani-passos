class User::Site::Create
  attr_accessor :company, :user_params, :address_params

  def initialize(company, user_params, address_params)
    @company = company
    @user_params = user_params
    @address_params = address_params
  end

  def call!
    password = user_params[:password]
    password = "temp@1234" if password.nil?

    user = company.users.find_by(email: user_params[:email], cpf: user_params[:cpf])
    user ||= company.users.create(user_params.merge({ password: password, password_confirmation: password, status: "active" }))
    response = user.set_address(address_params) if user.errors.blank?
    response ||= "Usuário Bloqueado pelo Administrador" if user.status == "inactive"

    if user.errors.present? || response.instance_of?(String)
      message = response || user.errors.full_messages.join(", ")
      return { message_error: message }
    end

    user
  end
end
