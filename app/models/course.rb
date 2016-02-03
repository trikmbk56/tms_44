class Course < ActiveRecord::Base
  has_many :user_courses, dependent: :destroy
  accepts_nested_attributes_for :user_courses, allow_destroy: true
  has_many :course_subjects, dependent: :destroy
  accepts_nested_attributes_for :course_subjects, allow_destroy: true
  has_many :superuser_courses, dependent: :destroy
  accepts_nested_attributes_for :superuser_courses, allow_destroy: true
  
  enum status: [:not_start, :trainning, :finish]

  validates :name, presence: true
  validates :description, presence: true

  def get_course_subjects
    list_course_subjects = Array.new
    Subject.all.each do |subject|
      if present_course_subjects.has_key? subject.id
        course_subject = present_course_subjects[subject.id]
      else
        course_subject = CourseSubject.new subject_id: subject.id
      end
      list_course_subjects << course_subject
    end
    list_course_subjects
  end

  def get_user_course user
    user_courses.find_by user_id: user.id
  end

  def get_superuser_course superuser
    superuser_courses.find_by superuser_id: superuser.id
  end

  def managed_by? superuser
    superuser_courses.find_by superuser_id: superuser.id
  end

  def has_user? user
    user_courses.find_by user_id: user.id
  end

  def get_course_subject subject
    course_subjects.find_by subject_id: subject.id
  end

  def present_course_subjects
    hash_course_subjects = Hash.new
    course_subjects.each do |course_subject|
      hash_course_subjects[course_subject.subject_id] = course_subject
    end
    hash_course_subjects
  end

  def load_users
    users = Array.new
    user_courses.each do |user_course|
      users << user_course.user
    end
    users
  end

  def load_subjects
    subjects = Array.new
    course_subjects.each do |course_subject|
      subjects << course_subject.subject
    end
    subjects
  end

  def load_admins
    admins = Array.new
    superuser_courses.each do |superuser_course|
      admins << superuser_course.superuser
    end
    admins
  end

  def create_course_subject_task
    course_subjects.each do |course_subject|
      course_subject.subject.tasks.each do |task|
        CourseSubjectTask.create course_subject: course_subject, task: task
      end
    end
  end
end
