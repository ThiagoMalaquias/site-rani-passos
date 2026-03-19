class PromoController < ApplicationController
  before_action :set_live
  layout "promo"

  def show; end

  private

  def set_live
    @live = LiveLesson.find_by(slug: params[:id])
    return if @live.present?

    redirect_to root_path
  end
end
