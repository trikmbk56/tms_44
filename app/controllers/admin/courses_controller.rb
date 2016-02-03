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
      @course.create_course_subject_task
      flash[:success] = t "admin.course.created"
      redirect_to admin_courses_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    case params[:status]
    when Settings.start
      if users_not_busy?
        flash[:success] = t "admin.course.start_success"
        update_course_start
        update_user_courses_start
        create_user_subjects
      else
        flash[:danger] = t "admin.course.start_error"
      end
      redirect_to :back
    when Settings.finish
      update_course_finish
      update_user_courses_finish
      update_course_subjects_finish
      update_user_subjects_finish
      flash[:success] = t "admin.course.finish_success"
      redirect_to admin_courses_path
    else
      if @course.update_attributes course_params
        flash[:success] = t "admin.course.updated"
        redirect_to :back
      else
        render :edit
      end
    end
  end

  def destroy
    @course.destroy
    flash[:success] = t "admin.course.deleted"
    redirect_to :back
  end

  private
  def course_params
    params.require(:course).permit :name, :description, :start_date, :end_date,
      course_subjects_attributes: [:id, :subject_id, :_destroy],
      user_courses_attributes: [:id, :user_id, :_destroy],
      superuser_courses_attributes: [:id, :superuser_id, :_destroy]
  end

  def add_current_superuser_to_course
    @superuser_course = SuperuserCourse.create course: @course,
      superuser: current_superuser
  end

  def load_course
    @course = Course.find params[:id]
  end

  def load_objects
    @users = @course.load_users
    @subjects = @course.load_subjects
    @admins = @course.load_admins
  end

  def users_not_busy?
    check = true
    @course.load_users.each do |user|
      check = false if user.is_working?
    end
    check
  end

  def update_course_start
    @course.update_attributes status: :trainning, start_date: Time.now
  end

  def update_user_courses_start
    @course.user_courses.each do |user_course|
      user_course.update_attributes status: :trainning
    end
  end

  def create_user_subjects
    @course.load_users.each do |user|
      @course.course_subjects.each do |course_subject|
        course_subject.user_subjects.create user: user
      end
    end
  end

  def update_course_finish
    @course.update_attributes status: :finish, end_date: Time.now
  end

  def update_user_courses_finish
    @course.user_courses.each do |user_course|
      user_course.update_attributes status: :finish
    end
  end

  def update_course_subjects_finish
    @course.course_subjects.each do |course_subject|
      course_subject.update_attributes status: :finish, end_date: Time.now
    end
  end

  def update_user_subjects_finish
    @course.load_users.each do |user|
      @course.course_subjects.each do |course_subject|
        user_subject = user.user_subjects.find_by course_subject_id: course_subject.id
        user_subject.update_attributes status: :finish
      end
    end
  end
end
