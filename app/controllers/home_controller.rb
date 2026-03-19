class HomeController < ApplicationController
  def index
    params[:slug] ||= "assinatura-rani-passos"
    @course = Course.find_by(slug: params[:slug])
    @courses = Course.where(id: [491, 48, 433]).order(Arel.sql("CASE id WHEN 491 THEN 1 WHEN 48 THEN 2 WHEN 433 THEN 3 END"))
    @testimonials = Testimonial.limit(5).order("RANDOM()")
  end

  def events
    render json: {}, status: :ok
  end
end
