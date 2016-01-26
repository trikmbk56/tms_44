class UserSubject < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_subject

  enum status: [:not_start, :trainning, :finish]
  
  scope :get_user_subject, -> course_subject_id, user_id{
    find_by user_id: user_id, course_subject_id: course_subject_id}
end
