class UserSiteAdvertisementsController < ApplicationController
  before_action :set_site_advertisement
  skip_before_action :verify_authenticity_token, only: [:create]

  def add_click
    if @site_advertisement.click.nil?
      @site_advertisement.click = 1
    else
      @site_advertisement.click += 1
    end

    @site_advertisement.save

    update_cookies

    if @site_advertisement.link.present?
      redirect_to @site_advertisement.link
    else
      redirect_to root_path
    end
  end

  def create
    update_cookies

    render json: {}, status: :ok
  end

  private

  def update_cookies
    viewed_ad_ids = cookies[:ead_advertisement].present? ? JSON.parse(cookies[:ead_advertisement]) : []
    viewed_ad_ids << @site_advertisement.id
    cookies[:ead_advertisement] = { value: viewed_ad_ids.to_json, expires: 1.year.from_now }
  end

  def set_site_advertisement
    @site_advertisement = SiteAdvertisement.actives.first
  end
end
