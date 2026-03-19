class ApplicationController < ActionController::Base
  before_action :site, :set_pop_up_leak, :set_utm_params, :clear_cashback_applied

  def site
    @site = ENV.fetch('SITE') { 'ranipassos' }
    @teacher = company.teacher
  end

  def company
    @company ||= Company.first
  end

  def set_pop_up_leak
    @pop_up_leak = SiteAdvertisement.actives.leak.first
    @pop_up_leak = nil if @pop_up_leak.nil?
  end

  def set_utm_params
    cookies[:utm_source] = params[:utm_source] if params[:utm_source].present?
    cookies[:utm_medium] = params[:utm_medium] if params[:utm_medium].present?
    cookies[:utm_campaign] = params[:utm_campaign] if params[:utm_campaign].present?
  end

  def clear_cashback_applied
    cookies.delete(:cashback_applied) if params[:controller] != "payments" && params[:action] != "cashback_interest"
    cookies.delete("ead_#{@site}_cart_user") if params[:controller] != "cart" && params[:controller] != "payments"
  end
end
