class LiveLessonsController < ApplicationController
  def index
    @live_lessons = LiveLesson.actives.current_month.order(start_date: :asc)
  end

  def show; end
end
