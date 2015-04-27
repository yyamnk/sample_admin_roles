class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
  belongs_to :role      # Userからroleを参照可能にする, ex) User.find(1).role
  has_one :user_detail  # UserからUserDetailを参照可能にする
  has_many :groups

  before_create :set_default_role

  def to_s # aciveAdminで表示名を指定する
    self.email
  end

  private

  def set_default_role
    self.role_id ||= Role.find(3).id  #デフォルトのRole.id
  end

end
