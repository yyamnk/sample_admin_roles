class Group < ActiveRecord::Base
  belongs_to :group_category
  belongs_to :user

  validates :name, presence: true, uniqueness: true
  validates :user, presence: true
  validates :activity, presence: true
  validates :group_category, presence: true

end
