class HomeController < ApplicationController
  def index
    params[:slug] ||= "assinatura-rani-passos"
    @course = Course.find_by(slug: params[:slug])
    @courses = Course.where(id: [491, 48, 433]).order(Arel.sql("CASE id WHEN 491 THEN 1 WHEN 48 THEN 2 WHEN 433 THEN 3 END"))
    @testimonials = Testimonial.limit(5).order("RANDOM()")
  end

  def metrics
    @course = Course.find_by(slug: params[:slug])
    @courses = Course.where.not(id: @course.id).disclosure_actives.paids.order("RANDOM()").limit(3)
    @testimonials = Testimonial.limit(5).order("RANDOM()")

    course_link = CourseLink.find_by(code: params[:code])
    if course_link.present?
      LinkAccess.create(course_link: course_link, metadata: request.env["HTTP_USER_AGENT"])
      cookies[:ead_code_metrics] = params[:code]
      params[:discount] = course_link.discount if course_link.discount.present?
    end

    render :index
  end

  def events
    render json: {}, status: :ok
  end
end
