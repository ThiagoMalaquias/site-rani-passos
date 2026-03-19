class UserCoursesController < ApplicationController
  before_action :set_course, only: [:new, :create]
  before_action :set_user, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]

  def thanks
    user_course = UserCourse.find(params[:id])
    @user = user_course.user
    @course = user_course.course
  end

  def new
    @user = User.find(cookies[:payment_user]) rescue nil if cookies[:payment_user].present?
  end

  def create
    user_courses = @user.user_courses.where(course_id: @course.id)
    if user_courses.count.positive?
      flash[:error] = "Você ja está cadastrado nesse curso!"
      redirect_to "#{new_user_course_path}?course=#{@course.slug}"
      return
    end

    @user_course = @user.user_courses.build({ course_id: @course.id, status: "active", access_start: Time.zone.now, access_until: access_until, lifetime: @course.lifetime })
    respond_to do |format|
      if @user_course.save
        WhatsappMessage.send_text(@user, "acquired_free_course") if WhatsappSendRule.first.acquired_free_course
        # EmailsMailer.access_free_course(@user_course).deliver
        tag = Tag.find_by(name: "Aluno-Free")
        UserTag.find_or_create_by(user: @user, tag: tag) if tag.present?
        save_ead_code_metrics(@user_course)

        format.html { redirect_to thanks_user_course_path(@user_course), notice: "Curso criado com sucesso." }
        format.json { render :show, status: :created, location: @user_course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_course.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User::Site::Create.new(company, user_params, address_params).call!

    unless @user.instance_of?(User)
      flash[:error] = @user[:message_error]
      redirect_to "/user_courses/new?course=#{@course.slug}"
      return
    end

    @user.update(user_params.merge(last_ip: request.remote_ip))
    cookies[:payment_user] = @user.id.to_s
  end

  def save_ead_code_metrics(user_course)
    return if cookies[:ead_code_metrics].blank?

    code = cookies[:ead_code_metrics]
    course_link = CourseLink.find_by(code: code)
    return if course_link.nil?

    LinkUserCourse.find_or_create_by(course_link: course_link, user_course: user_course)
    cookies[:ead_code_metrics] = nil
  end

  def set_course
    @course = Course.find_by(slug: params[:course])
    return unless @course.nature == "paid"

    redirect_to "#{new_cart_path}?course=#{@course.slug}"
    return
  end

  def access_until
    return nil if @course.lifetime

    Time.zone.now + @course.period_access.month
  end

  def user_params
    params.require(:user).permit(:name, :email, :cpf, :phone)
  end

  def address_params
    params.require(:address).permit(:posta_code, :street, :number, :neighborhood, :city, :uf)
  end
end
