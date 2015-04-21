class UserDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  belongs_to :grade
end
