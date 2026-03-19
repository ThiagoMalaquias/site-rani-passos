class LeadsController < ApplicationController
  before_action :set_live_lesson
  skip_before_action :verify_authenticity_token, only: [:create]

  def show; end

  def create
    @lead = @live_lesson.leads.find_by(email: lead_params[:email])
    if @lead.present?
      render :show, status: :ok, location: @lead
      return
    end

    @lead = @live_lesson.leads.build(lead_params)
    if @lead.save
      render :show, status: :created, location: @lead
    else
      render json: @lead.errors, status: :unprocessable_entity
    end
  end

  private

  def set_live_lesson
    if params[:live_lesson_slug].present?
      @live_lesson = LiveLesson.find_by(slug: params[:live_lesson_slug])
      return
    end

    @live_lesson = LiveLesson.find(params[:live_lesson_id])
  end

  def lead_params
    params.permit(:name, :email, :phone)
  end
end
