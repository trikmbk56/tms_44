class UserCourse < ActiveRecord::Base
  belongs_to :user
  belongs_to :course

  enum status: [:not_start, :trainning, :finish]
end
