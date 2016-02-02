module UserCoursesHelper
  def course_status user_course_status
    status = Settings.status[user_course_status]
    @label_class = status.label_class
    @status_text = status.title
  end

  def finish_subject course_subject
    if course_subject.finish?
      flash[:danger] = t "subject.finished"
    elsif course_subject.trainning?
      user_subject = current_user.user_subjects.
        find_by course_subject_id: course_subject.id
      tasks = course_subject.course_subject_tasks
      tasks.each do |task|
        finish_task task
      end
      update_course_subject course_subject, user_subject
    else
      flash[:danger] = t "subject.error_not_start"
    end
  end

  def finish_task course_subject_task
    user_subject = current_user.user_subjects.
      find_by course_subject: course_subject_task.course_subject
    if user_subject.finish?
      flash[:danger] = t "subject.finished"
    elsif user_subject.trainning?
      user_task = current_user.user_tasks.
        find_by course_subject_task_id: course_subject_task
      if user_task.nil?
        current_user.user_tasks.create course_subject_task: course_subject_task,
          status: :finish
      end
    else
      flash[:danger] = t "subject.error_not_start"
    end
  end

  def update_course_subject course_subject, user_subject
    user_subject.update_attributes status: :finish, finish_date: Time.now
    description = course_subject.subject.name + " " + "finish"
    Activity.update_activity current_user.id, course_subject,
      Settings.target_type.subject, description
  end
end
