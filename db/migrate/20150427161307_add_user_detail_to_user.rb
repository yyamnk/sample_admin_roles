class AddUserDetailToUser < ActiveRecord::Migration
  def change
    add_reference :users, :user_detail, index: true, foreign_key: true
  end
end
