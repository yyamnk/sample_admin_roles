class GroupCategory < ActiveRecord::Base

  has_many :groups

  # 必須入力
  validates :name_ja, presence: true
  # あとでname_enもたす

  def to_s # aciveAdminで表示名を指定する
    self.name_ja
  end

end
