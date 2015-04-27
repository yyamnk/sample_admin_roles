class Role < ActiveRecord::Base
  has_many :users

  validates :name,
    presence: true,  # 必須
    uniqueness: true # 重複不可
end
