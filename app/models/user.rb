class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
  belongs_to :role # Userからroleを参照可能にする, ex) User.find(1).role

  before_create :set_default_role

  private

  def set_default_role
    self.roles_id ||= Role.find(3).id  #デフォルトのRole.id
  end
end
