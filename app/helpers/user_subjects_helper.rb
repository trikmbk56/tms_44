module UserSubjectsHelper
  def get_subject_status course_subject_id
    user_subject = UserSubject.get_user_subject course_subject_id, current_user.id
    get_status user_subject.status
  end

  def user_task_status course_subject_task_id
    user_task = UserTask.find_by user_id: current_user,
      course_subject_task_id: course_subject_task_id
    get_status user_task.status
  end

  private
  def get_status status
    status = Settings.status[status]
    @task_class = status.status_class
    @check_box_status = status.check_box
    @check_box_text = status.title
  end
end
