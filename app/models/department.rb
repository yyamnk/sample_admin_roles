class Department < ActiveRecord::Base
  has_many :users

  def to_s # aciveAdminで表示名を指定する
    self.name_ja
  end
end
