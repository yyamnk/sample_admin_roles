class Users::Mailer < Devise::Mailer

  # copy from
  # https://github.com/plataformatec/devise/wiki/How-To:-Use-custom-mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  # default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  # if I18n.default_locale == ':ja'
  #   default template_path: 'users/mailer/ja'
  # end
  def headers_for(action, opts)
    # localeで判定したい.
    super.merge!({template_path: '/users/ja'})
    # this moves the Devise template path to /views/users/ja
  end
end
