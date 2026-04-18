class HomeController < ApplicationController
  COMPARISON_SLUG_ASSINATURA = "assinatura-rani-passos".freeze
  COMPARISON_SLUG_MENTORIA   = "mentoria-missao-gabaritar".freeze
  COMPARISON_DEFAULT_SLUG    = COMPARISON_SLUG_ASSINATURA

  before_action :set_courses, only: [:index, :metrics]

  def index; end

  def companies; end

  def metrics
    course_link = CourseLink.find_by(code: params[:code])
    if course_link.present?
      LinkAccess.create(course_link: course_link, metadata: request.env["HTTP_USER_AGENT"])
      cookies[:ead_code_metrics] = params[:code]
      params[:discount] = course_link.discount if course_link.discount.present?
    end

    render :index
  end

  def courses
    @courses = Course.disclosure_actives.rani_passos

    @courses = @courses.paids if params[:nature].nil? || params[:nature].blank?
    @courses = @courses.free if params[:nature].present?

    @courses = @courses.usuals if params[:kind].nil? || params[:kind].blank?
    @courses = @courses.simulateds if params[:kind].present?
    @courses = @courses.mentorings if params[:mentoring].present?

    @courses = @courses.joins(:course_categories).distinct.where("course_categories.category_id in (#{params[:categoria].join(',')})") if params[:categoria].present?

    @categories = Category.disclosure_actives.order("order_sequences asc")
    @categories_featureds = @categories.limit(6)

    options = { page: params[:page] || 1, per_page: 9 }
    @courses = @courses.paginate(options)
  end

  def testimonials
    @testimonials = Testimonial.all
    @medias = TestimonialMedium.all
  end

  def events
    render json: {}, status: :ok
  end

  def search
    @courses = Course.disclosure_actives

    if params[:course].present?
      @courses = @courses.where("(lower(title) ilike '%#{params[:course].downcase}%') OR
      (lower(description) ilike '%#{params[:course].downcase}%') OR
      (lower(tags) ilike '%#{params[:course].downcase}%')")
    end

    options = { page: params[:page] || 1, per_page: 8 }
    @courses = @courses.paginate(options)
  end

  private

  def set_courses
    slug = params[:slug].presence || COMPARISON_DEFAULT_SLUG
    @course = Course.find_by(slug: slug)
    comparison_slugs = comparison_slug_order(slug)
    @courses = courses_ordered_for_comparison(comparison_slugs)

    @testimonials = Testimonial.limit(5).order("RANDOM()")
    @faqs = Faq.actives
  end

  def comparison_slug_order(current_slug)
    case current_slug
    when COMPARISON_SLUG_ASSINATURA
      [COMPARISON_SLUG_ASSINATURA, COMPARISON_SLUG_MENTORIA]
    when COMPARISON_SLUG_MENTORIA
      []
    else
      [current_slug, COMPARISON_SLUG_ASSINATURA].uniq
    end
  end

  def courses_ordered_for_comparison(slugs)
    return Course.none if slugs.blank?

    quoted = slugs.map { |s| Course.connection.quote(s) }.join(", ")
    Course.where(slug: slugs).order(
      Arel.sql("array_position(ARRAY[#{quoted}]::varchar[], courses.slug::varchar)")
    )
  end
end
