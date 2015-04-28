class UserDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
  belongs_to :grade

  # 必須入力
  validates :user_id, :department_id, :grade_id, :tel, :name_ja, :name_en, presence: true

  validates :user_id, uniqueness: true                     # 重複不可
  validates :name_en, format: { with: /\A[a-zA-Z\s]+\z/i } # 半角英字と半角スペースのみ
  # tel -> 半角数字とハイフンのみ, ( [333-4444-4444, for 携帯], [4444-22-4444, for 固定] )
  validates :tel,     format: { with: /(\A\d{3}-\d{4}-\d{4}+\z)|(\A\d{4}-\d{2}-\d{4})+\z/i }

  def to_s # aciveAdminで表示名を指定する
    self.name_ja
  end
end
