class WelcomeController < ApplicationController
  authorize_resource :class => false # for cancancan

  def index
    @user = current_user # deviseでログインしているユーザを取得

    # UserDetail.find( id )だと存在しな時にエラー吐く. nilを渡すようにする
    @user_detail = UserDetail.find_by(id: current_user.id)
  end
end
