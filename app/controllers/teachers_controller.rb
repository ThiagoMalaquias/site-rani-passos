class TeachersController < ApplicationController
  def index
    @instructors = Instructor.disclosure_actives.order(created_at: :asc)
  end
end