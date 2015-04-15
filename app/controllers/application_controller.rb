class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #サインイン後の遷移先
  def after_sign_in_path_for(resource)
    welcome_index_path
    # rake routesの<prefix>_pathで飛ぶ.
    # root_pathはダメだった.
  end

  #ログアウト後の遷移先
  def after_sign_out_path_for(resource)
    admin_root_path
  end
end
