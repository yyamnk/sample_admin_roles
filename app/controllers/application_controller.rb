class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #サインアップ後の遷移先は`app/controllers/registrations_controller.rb`に書く

  #サインイン後の遷移先
  def after_sign_in_path_for(resource)
    welcome_index_path
    # rake routesの<prefix>_pathで飛ぶ.
    # root_pathはダメだった.
  end

  #ログアウト後の遷移先
  def after_sign_out_path_for(resource)
    root_path
  end

  #active_admin配下へ許可されていないユーザがアクセスした場合の遷移先
  #リダイレクトループ抑止でも必要
  def access_denied(exception)
    redirect_to new_user_session_path, :alert => exception.message
  end

  # cancancanで拒否された場合補足
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
  end

end
