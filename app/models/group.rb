class Group < ActiveRecord::Base
  belongs_to :group_category
  belongs_to :user
end
