class UserSubjectsController < ApplicationController
  before_filter :logged_in_user

  def index
    @user_subjects = UserSubject.get_user_subjects current_user.id
  end

  def show
    @user_subject = current_user.user_subjects.find_by id: params[:id]
    if @user_subject.nil?
      redirect_to user_subjects_path
    else
      @course_subject_tasks = @user_subject.course_subject.course_subject_tasks
      @activities = Activity.get_activities current_user.id,
        Settings.target_type.subject, @user_subject.course_subject.id
      @title_for_layout = t("subject.title") +
        @user_subject.course_subject.subject.name
    end
  end
end
