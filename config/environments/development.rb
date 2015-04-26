Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  # config.assets.debug = true
  config.assets.debug = false

  # assetsまわりで不可解な挙動をした場合は,
  # 1. プリコンパイルされたファイルを全て削除
  #   bundle exec rake assets:clobber
  # 2. config.assets.debug = falseでサーバ再起動
  # 3. trueに書き換え
  # を行う

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  #

  # ---------------------------
  # ActionMailer Config
  # for device, e-mail
  # ---------------------------
  # sample settings
  # https://github.com/RailsApps/rails-devise/blob/master/config/environments/development.rb
  # `Rails.application.secrets.[domain_name, email_username, email_password]`は
  # `config/secrets.yml`で定義される (このとき環境変数を読み込むべき)
  config.action_mailer.smtp_settings = {
    address: Rails.application.secrets.smtp_adress,
    port: Rails.application.secrets.smtp_port,
    domain: Rails.application.secrets.domain_name,
    authentication: Rails.application.secrets.smtp_auth,
    tls: Rails.application.secrets.smtp_tls,
    enable_starttls_auto: true,
    user_name: Rails.application.secrets.email_username,
    password: Rails.application.secrets.email_password
  }
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_options = {
    bcc: Rails.application.secrets.email_bcc
  }
  config.action_mailer.raise_delivery_errors = true
  # Send email in development mode?
  config.action_mailer.perform_deliveries = true

end
