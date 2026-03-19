class CampaignsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:status_webhook]

  def status_webhook
    data = params['_json'].first

    user = CampaignUser.find_by(message_id: data['email_log_id']) if data['email_log_id'].present?
    
    if user.present?
      user.update(opened: true) if data['event'] == "open"
      user.update(clicked: true) if data['event'] == "click"
    end

    render json: {}, status: :ok
  rescue Exception => e
    Rails.logger.info "Erro ao processar webhook: #{params.inspect} - #{e.message} - #{e.backtrace}"
    render json: {}, status: :ok
  end
end