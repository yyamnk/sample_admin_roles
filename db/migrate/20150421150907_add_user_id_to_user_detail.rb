class AddUserIdToUserDetail < ActiveRecord::Migration
  def change
    add_reference :user_details, :user, index: true, foreign_key: true
  end
end
