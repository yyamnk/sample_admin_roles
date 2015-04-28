class RegistrationsController < ActiveAdmin::Devise::RegistrationsController

  # ref
  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-up-(registration)
  def after_inactive_sign_up_path_for(resource) # サインアップしたけどメール認証が終わってない場合
    # '/an/example/path'
    '/admin/login'
  end
end
