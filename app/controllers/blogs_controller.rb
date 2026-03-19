class BlogsController < ApplicationController
  before_action :set_blog, only: [:show]

  def index
    @blogs = Blog.actives.order(favorite: :desc)

    if params[:search].present?
      @blogs = @blogs.where("(lower(title) ilike '%#{params[:search].downcase}%') OR
      (lower(content) ilike '%#{params[:search].downcase}%')")
    end

    options = { page: params[:page] || 1, per_page: 9 }
    @blogs = @blogs.paginate(options)
  end

  def show
    @blog.clicks += 1
    @blog.save
  end

  private

  def set_blog
    @blog = Blog.find_by(slug: params[:id])
  end
end
