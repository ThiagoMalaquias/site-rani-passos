class CampaignUserSearchService
  attr_reader :campaign, :params

  def initialize(campaign, params)
    @campaign = campaign
    @params = params
    @users = User.order(name: :asc)
  end

  def search_users_by_segment
    search_by_tags if campaign.segment == "tag"
    search_by_states if campaign.segment == "state"
    search_by_courses if campaign.segment == "course"
    search_by_categories if campaign.segment == "category"
    search_by_sales if campaign.segment == "sale"
    search_by_abandoned_carts if campaign.segment == "abandoned_cart"
    search_by_access_courses if campaign.segment == "access_course"

    @users
  end

  private

  def search_by_tags
    if params[:tags].present?
      tag_ids = params[:tags].reject(&:blank?)
      if tag_ids.any?
        @users = @users.joins(:user_tags)
                       .where(user_tags: { tag_id: tag_ids })
                       .group('users.id')
                       .having('COUNT(DISTINCT user_tags.tag_id) = ?', tag_ids.size)
      end
    elsif params[:tag].present?
      @users = @users.joins(:user_tags).distinct.where(user_tags: { tag_id: params[:tag] })
    end
  end

  def search_by_states
    if params[:states].present?
      state_ids = params[:states].reject(&:blank?)
      if state_ids.any?
        @users = @users.joins(:addresses).distinct.where(addresses: { uf: state_ids })
      end
    end
  end

  def search_by_courses
    if params[:courses].present?
      course_ids = params[:courses].reject(&:blank?)
      if course_ids.any?
        @users = @users.joins(user_courses: :course).distinct
                       .where(courses: { id: course_ids })
                       .group('users.id')
                       .having('COUNT(DISTINCT courses.id) = ?', course_ids.size)
      end
    end

    if params[:nature].present? && params[:nature] != "all"
      @users = @users.joins(user_courses: :course).distinct.where({ courses: { nature: params[:nature] }  })
    end
  end

  def search_by_categories
    if params[:categories].present?
      category_ids = params[:categories].reject(&:blank?)
      if category_ids.any?
        @users = @users.joins(user_courses: { course: :course_categories })
          .where(course_categories: { category_id: category_ids })
          .group('users.id')
          .having('COUNT(DISTINCT course_categories.category_id) = ?', category_ids.size)
      end
    end
  end

  def search_by_sales
    @users = @users.joins(:payments).distinct

    if params[:status].present?
      @users = @users.where(payments: { status: params[:status] })
    end

    if params[:start_date].present? && params[:end_date].present?
      @users = @users.where("TO_CHAR(payments.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(payments.created_at - interval '3 hour','YYYY-MM-DD') <= ?", params[:start_date], params[:end_date]) 
    end

    if params[:course_id].present?
      @users = @users.joins(payments: :user_courses)
                     .where(user_courses: { course_id: params[:course_id] })
                     .where.not(user_courses: { amount: nil })
                     .distinct
    end
  end

  def search_by_abandoned_carts
    params[:start_date] ||= Date.current.beginning_of_month.strftime("%Y-%m-%d")
    params[:end_date] ||= Date.current.end_of_month.strftime("%Y-%m-%d")

    @users = User.joins(:open_carts)
                .select("users.*, MAX(user_open_carts.created_at - INTERVAL '3 hours') as last_cart_date")
                .group('users.id')
                .having("MAX(user_open_carts.created_at - INTERVAL '3 hours') BETWEEN ? AND ?", 
                       params[:start_date].to_date, 
                       params[:end_date].to_date)
                .order('last_cart_date DESC')

    @users = @users.where(user_open_carts: { course_id: params[:course_id] }) if params[:course_id].present?
  end

  def search_by_access_courses
    @users = @users.joins(:tracks).distinct

    if params[:course_id].present?
      @users = @users.where(tracks: { course_id: params[:course_id] })
    end

    if params[:start_date].present? && params[:end_date].present?
      @users = @users.where("TO_CHAR(tracks.created_at - interval '3 hour','YYYY-MM-DD') >= ? and TO_CHAR(tracks.created_at - interval '3 hour','YYYY-MM-DD') <= ?", params[:start_date], params[:end_date]) 
    end
  end
end
