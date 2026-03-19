class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :apply_discount, :metrics]

  def index
    @courses = Course.disclosure_actives

    @courses = @courses.paids if params[:nature].nil? || params[:nature].blank?
    @courses = @courses.free if params[:nature].present?

    @courses = @courses.usuals if params[:kind].nil? || params[:kind].blank?
    @courses = @courses.simulateds if params[:kind].present?
    @courses = @courses.mentorings if params[:mentoring].present?

    if params[:search].present?
      @courses = @courses.where("(lower(title) ilike '%#{params[:search].downcase}%') OR
      (lower(description) ilike '%#{params[:search].downcase}%') OR
      (lower(tags) ilike '%#{params[:search].downcase}%')")
    end

    @courses = @courses.joins(:course_categories).distinct.where("course_categories.category_id in (#{params[:categoria].join(',')})") if params[:categoria].present?

    @categories = Category.disclosure_actives.order("order_sequences asc")
    @categories_featureds = @categories.limit(6)

    options = { page: params[:page] || 1, per_page: 9 }
    @courses = @courses.paginate(options)
  end

  def metrics
    @courses = Course.where.not(id: @course.id).disclosure_actives.paids.order("RANDOM()").limit(3)

    @testimonials = Testimonial.limit(5).order("RANDOM()")
    course_link = CourseLink.find_by(code: params[:code])
    if course_link.present?
      LinkAccess.create(course_link: course_link, metadata: request.env["HTTP_USER_AGENT"])
      cookies[:ead_code_metrics] = params[:code]
      params[:discount] = course_link.discount if course_link.discount.present?
    end

    render :show
  end

  def show
    @courses = Course.where(id: [491, 48, 433]).order(Arel.sql("CASE id WHEN 491 THEN 1 WHEN 48 THEN 2 WHEN 433 THEN 3 END"))

    @testimonials = Testimonial.limit(5).order("RANDOM()")
  end

  private

  def set_course
    @course = Course.find(params[:id])
  rescue
    @course = Course.find_by(slug: params[:id])
  end
end
