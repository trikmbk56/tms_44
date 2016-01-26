class Admin::CoursesController < ApplicationController
  layout "admin"
  before_action :logged_in_superuser
  before_action :load_course, only: [:edit, :update, :destroy, :show]
  before_action :load_objects, only: [:show]

  def index
    @courses = Course.paginate page: params[:page]
  end

  def show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new course_params
    if @course.save
      add_current_superuser_to_course
      flash[:success] = t "admin.course.created"
      redirect_to admin_courses_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @course.update_attributes course_params
      flash[:success] = t "admin.course.updated"
      redirect_to admin_courses_path
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    flash[:success] = t "admin.course.deleted"
    redirect_to admin_courses_path
  end

  private
  def course_params
    params.require(:course).permit :name, :description, :start_date, :end_date,
      course_subjects_attributes: [:id, :subject_id, :_destroy]
  end

  def add_current_superuser_to_course
    @superuser_course = SuperuserCourse.create course: @course,
      superuser: current_superuser
  end

  def load_course
    @course = Course.find params[:id]
  end

  def load_objects
    @subjects, @admins, @users = Array.new, Array.new, Array.new
    @course.course_subjects.each do |course_subject|
      @subjects << course_subject.subject
    end
    @course.superuser_courses.each do |superuser_course|
      @admins << superuser_course.superuser
    end
    @course.user_courses.each do |user_course|
      @users << user_course.user
    end
  end
end
