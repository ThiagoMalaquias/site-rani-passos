class ContactsController < ApplicationController
  before_action :validate_email, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]

  def index; end

  def create
    if verify_recaptcha
      @contact = company.contacts.build(contact_params.merge(status: 'active'))

      respond_to do |format|
        if @contact.save
          EmailsMailer.received_contact(@contact).deliver
          EmailsMailer.admin_received_contact(@contact).deliver
          format.html { redirect_to contacts_url, notice: "Contato criado com sucesso" }
        else
          format.html { redirect_to contacts_url, notice: "Preencha todos os campos" }
        end
      end
    else
      flash[:error] = "Clique na opção - Não sou um robô - (Captcha inválido)"
      redirect_to contacts_url
    end
  end

  private

  def validate_email
    email = contact_params[:email]
    emails_negados = ["cortez.walls@yahoo.com", "ericjonesmyemail@gmail.com"]

    if emails_negados.include?(email) || !email.include?(".com")
      redirect_to contacts_url
      return
    end
  end

  def contact_params
    params.require(:contact).permit(:name, :email, :phone, :message)
  end
end
