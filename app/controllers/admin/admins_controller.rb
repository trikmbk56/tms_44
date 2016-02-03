class Admin::AdminsController < ApplicationController
  layout "admin"
  before_action :logged_in_superuser
  before_action :load_objects, only: [:index]

  def index
  end

  private
  def load_objects
    @course = Course.find params[:course_id]
    @admins = Superuser.all
  end
end
