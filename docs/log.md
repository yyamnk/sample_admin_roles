# README

管理画面と管理権限の実装テスト


```
bundle init
vim Gemfile
# Gemfileの`gem "rails"`をコメントイン

bundle install --path vendor/bundle --jobs=4
# jobsは並列処理数
```

commit: `0c678ad`

```sh
bundle exec rails new . --git -d postgresql -T
```

commit: `0e24669`

```
# Gemfile

# 追加
gem 'activeadmin', github: 'activeadmin'
```

```sh
bundle
```

commit: `7303e33`

```sh
# AdminUser (デフォルト) ではなく,  Userモデルを使う?
rails g active_admin:install User
```

deviceがなくて怒られる.

```
# Gemfile

# 追加
gem 'devise'
```

[公式ドキュメント](https://github.com/activeadmin/activeadmin/blob/master/docs/0-installation.md)に従ってインストールする


```sh
bundle exec rails g active_admin:install User

#ログ
      invoke  devise
    generate    devise:install
      create    config/initializers/devise.rb
      create    config/locales/devise.en.yml
  ===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:

       config.assets.initialize_on_precompile = false

     On config/application.rb forcing your application to not access the DB
     or load models when precompiling your assets.

  5. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================
      invoke    active_record
      create      db/migrate/20150323132516_devise_create_users.rb
      create      app/models/user.rb
      insert      app/models/user.rb
       route    devise_for :users
        gsub    app/models/user.rb
        gsub    config/routes.rb
      insert    db/migrate/20150323132516_devise_create_users.rb
      create  config/initializers/active_admin.rb
      create  app/admin
      create  app/admin/dashboard.rb
      create  app/admin/user.rb
      insert  config/routes.rb
    generate  active_admin:assets
      create  app/assets/javascripts/active_admin.js.coffee
      create  app/assets/stylesheets/active_admin.css.scss
      create  db/migrate/20150323132524_create_active_admin_comments.rb
```

commit: `50089f5`

active_adminのファイルと, deviseで認証に使うUserモデルが作成されたみたい.

[active_admin+devise+cancancan](http://codeonhill.com/devise-cancan-and-activeadmin/)を参考にすると, 

* Userモデルにroleを追加
* 管理者を作成

している.
管理者の登録はコンソールからやりたい.


```
rake db:create
rake db:migrate
```

設定をいじらずに`/admin`から`active_admin`にログインできた.

```
# config/initializers/active_admin.rb

  config.authentication_method = :authenticate_user!
  config.current_user_method = :current_user
  config.logout_link_path = :destroy_user_session_path
```

になっていた.
`rails g active_admin:install User`が正しく反映されたみたい.

ここまで: `c128edb`

production環境で動作確認

```sh 
bundle exec rails s -e production
# エラー
`raise_no_secret_key': Devise.secret_key was not set. Please add the following to your Devise initializer:
```

になった.

[rakeがDevise.secret_key was not setと出て失敗するときの対処法](http://hack.aipo.com/archives/7992/)
を参考に, `config/initializers/devise.rb`に追加する.

ソースにsecret_keyを入れたくない.
環境変数から設定する.

```
# config/initializers/devise.rb

Devise.setup do |config|
    ...
  config.secret_key = ENV['DEVICE_SECRET_KEY']
    ...
```

これで

```
bundle exec rails s -e production
```

が走るようになった.

ここまで: `b05ae4a`

productionのDBを作成する

```sh
createuser -P -d test_admin_permission
# パスワードにTEST_ADMIN_PERMISSION_DATABASE_PASSWORDと同じものを入れる.
```

これで

```
rake db:create RAILS_ENV=production
rake db:migrate RAILS_ENV=production
bundle exec rails s -e production
```

<http://localhost:3000/admin/login>にアクセスできた.

css, jsが動いてないのでプリコンパイルする

```
rake assets:precompile RAILS_ENV=production
```

css, jsが適用された.

ここまで: `9ef028a`


##デフォルトで作成されたUser情報を考える

* User
    * 既存のカラム (サンプルユーザ)
        * id: 1, 
        * email: "admin@example.com", 
        * encrypted_password: "$2a$10$57W6oslmesmJi8hKrMKpkeVBH1wkKX0Uwb4B8b.TYSp...", 
        * reset_password_token: nil, 
        * reset_password_sent_at: nil, 
        * remember_created_at: nil, 
        * sign_in_count: 2, 
        * current_sign_in_at: "2015-04-02 13:01:23", 
        * last_sign_in_at: "2015-04-02 12:54:28", 
        * current_sign_in_ip: #<IPAddr: IPv6:0000:0000:0000:0000:0000:0000:0000:0001/ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff>, 
        * last_sign_in_ip: #<IPAddr: IPv6:0000:0000:0000:0000:0000:0000:0000:0001/ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff>, 
        * created_at: "2015-04-02 12:53:56", 
        * updated_at: "2015-04-02 13:01:23"

`db/migrate/yyyymmdd..._devise_create_users.rb`に一致.

## devise passwordのリカバリー動作を確認する

[fogot your password](http://localhost:3000/admin/password/new)よりE-mailを入力 -> Reset my password
でエラー

```
Missing host to link to! Please provide the :host parameter, set default_url_options[:host], or set :only_path to true
```

```
# config/environments/development.rb へ追加

  # ---------------------------
  # for device, e-mail
  # ---------------------------
  # sample settings
  # https://github.com/RailsApps/rails-devise/blob/master/config/environments/development.rb
  # `Rails.application.secrets.[domain_name, email_username, email_password]`は
  # `config/secrets.yml`で定義される (このとき環境変数を読み込むべき)
  config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: Rails.application.secrets.domain_name,
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: Rails.application.secrets.email_username,
      password: Rails.application.secrets.email_password
    }
    # ActionMailer Config
    config.action_mailer.default_url_options = { :host => 'localhost:3000' }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    # Send email in development mode?
    config.action_mailer.perform_deliveries = true
```

`Rails.application.secrets.hoge`は`config/secrets.yml`で定義される.

```
development:
  secret_key_base: 40ab42d9149fffa5274b0de78ac82b521ff5aac1004a132a8a3e46cfa495a6a7849f496bf17bc7f3a7eb0c97a128d0393e07be5a18f61a8b77edcc6b84f1e322
  domain_name: <%= ENV["EMAIL_DOMAIN"] %>
  email_username: <%= ENV["EMAIL_USERNAME"] %>
  email_password: <%= ENV["EMAIL_PASSWORD"] %>

production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  domain_name: <%= ENV["EMAIL_DOMAIN"] %>
  email_username: <%= ENV["EMAIL_USERNAME"] %>
  email_password: <%= ENV["EMAIL_PASSWORD"] %>
```

development, productionに`domain_name`, `email_username`, `email_password`を追加.

```
# ~/.zshrc.local に追加

# for rails action mailer
export EMAIL_DOMAIN=gmail.com
export EMAIL_USERNAME='hoge@gmail.com'
export EMAIL_PASSWORD='hogefuga'
```

`source ~/.zshrc.local`して`bundle exec rails s`からメール送れた.

gmailは2段階認証を許可して, アプリ用の鍵を生成する必要がある.
[ココ](http://stackoverflow.com/questions/25597507/netsmtpauthenticationerror)を参考にした.

端末を`その他`から`Device`と入力して鍵を作成した.


# divese registableにする

active_adminでdeviseをインストールすると, userはwebページから新規追加できない.
これを新規追加可能にする


```
 class User < ActiveRecord::Base
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
-  devise :database_authenticatable,
-         :recoverable, :rememberable, :trackable, :validatable
+  devise :database_authenticatable,
+         :recoverable, :rememberable, :trackable, :validatable, :registerable
```

`:registerable`追加前

```
rake routes                                                                                                                    [/Volumes/Data/Dropbox/nfes15/test_admin_permission]
                  Prefix Verb       URI Pattern                         Controller#Action
        new_user_session GET        /admin/login(.:format)              active_admin/devise/sessions#new
            user_session POST       /admin/login(.:format)              active_admin/devise/sessions#create
    destroy_user_session DELETE|GET /admin/logout(.:format)             active_admin/devise/sessions#destroy
           user_password POST       /admin/password(.:format)           active_admin/devise/passwords#create
       new_user_password GET        /admin/password/new(.:format)       active_admin/devise/passwords#new
      edit_user_password GET        /admin/password/edit(.:format)      active_admin/devise/passwords#edit
                         PATCH      /admin/password(.:format)           active_admin/devise/passwords#update
                         PUT        /admin/password(.:format)           active_admin/devise/passwords#update
              admin_root GET        /admin(.:format)                    admin/dashboard#index
         admin_dashboard GET        /admin/dashboard(.:format)          admin/dashboard#index
batch_action_admin_users POST       /admin/users/batch_action(.:format) admin/users#batch_action
             admin_users GET        /admin/users(.:format)              admin/users#index
                         POST       /admin/users(.:format)              admin/users#create
          new_admin_user GET        /admin/users/new(.:format)          admin/users#new
         edit_admin_user GET        /admin/users/:id/edit(.:format)     admin/users#edit
              admin_user GET        /admin/users/:id(.:format)          admin/users#show
                         PATCH      /admin/users/:id(.:format)          admin/users#update
                         PUT        /admin/users/:id(.:format)          admin/users#update
                         DELETE     /admin/users/:id(.:format)          admin/users#destroy
          admin_comments GET        /admin/comments(.:format)           admin/comments#index
                         POST       /admin/comments(.:format)           admin/comments#create
           admin_comment GET        /admin/comments/:id(.:format)       admin/comments#show
```


`:registerable`追加後

```
rake routes                                                                                                                    [/Volumes/Data/Dropbox/nfes15/test_admin_permission]
                  Prefix Verb       URI Pattern                         Controller#Action
        new_user_session GET        /admin/login(.:format)              active_admin/devise/sessions#new
            user_session POST       /admin/login(.:format)              active_admin/devise/sessions#create
    destroy_user_session DELETE|GET /admin/logout(.:format)             active_admin/devise/sessions#destroy
           user_password POST       /admin/password(.:format)           active_admin/devise/passwords#create
       new_user_password GET        /admin/password/new(.:format)       active_admin/devise/passwords#new
      edit_user_password GET        /admin/password/edit(.:format)      active_admin/devise/passwords#edit
                         PATCH      /admin/password(.:format)           active_admin/devise/passwords#update
                         PUT        /admin/password(.:format)           active_admin/devise/passwords#update
cancel_user_registration GET        /admin/cancel(.:format)             active_admin/devise/registrations#cancel
       user_registration POST       /admin(.:format)                    active_admin/devise/registrations#create
   new_user_registration GET        /admin/sign_up(.:format)            active_admin/devise/registrations#new
  edit_user_registration GET        /admin/edit(.:format)               active_admin/devise/registrations#edit
                         PATCH      /admin(.:format)                    active_admin/devise/registrations#update
                         PUT        /admin(.:format)                    active_admin/devise/registrations#update
                         DELETE     /admin(.:format)                    active_admin/devise/registrations#destroy
              admin_root GET        /admin(.:format)                    admin/dashboard#index
         admin_dashboard GET        /admin/dashboard(.:format)          admin/dashboard#index
batch_action_admin_users POST       /admin/users/batch_action(.:format) admin/users#batch_action
             admin_users GET        /admin/users(.:format)              admin/users#index
                         POST       /admin/users(.:format)              admin/users#create
          new_admin_user GET        /admin/users/new(.:format)          admin/users#new
         edit_admin_user GET        /admin/users/:id/edit(.:format)     admin/users#edit
              admin_user GET        /admin/users/:id(.:format)          admin/users#show
                         PATCH      /admin/users/:id(.:format)          admin/users#update
                         PUT        /admin/users/:id(.:format)          admin/users#update
                         DELETE     /admin/users/:id(.:format)          admin/users#destroy
          admin_comments GET        /admin/comments(.:format)           admin/comments#index
                         POST       /admin/comments(.:format)           admin/comments#create
           admin_comment GET        /admin/comments/:id(.:format)       admin/comments#show
```

やってみたら, e-mail認証がかかっていなかった.

ここまで: `43ecd62`


# deviseでregistable & confirmableにする

[公式wiki](https://github.com/plataformatec/devise/wiki/How-To:-Add-:confirmable-to-Users)に書いてあるみたい.

そのとおりにやる

```sh
bundle exec rails g migration add_confirmable_to_devise
```

作成されたマイグレーションを編集

```
# db/migrate/20150414145341_add_confirmable_to_devise.rb

class AddConfirmableToDevise < ActiveRecord::Migration
  # Note: You can't use change, as User.update_all will fail in the down migration
  def up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    # add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
    add_index :users, :confirmation_token, unique: true
    # User.reset_column_information # Need for some types of updates, but not for update_all.
    # To avoid a short time window between running the migration and updating all existing
    # users as confirmed, do the following
    execute("UPDATE users SET confirmed_at = NOW()")
    # All existing user accounts should be able to log in after this.
  end

  def down
    remove_columns :users, :confirmation_token, :confirmed_at, :confirmation_sent_at
    # remove_columns :users, :unconfirmed_email # Only if using reconfirmable
  end
end
```

views生成

```
be rails g devise:views users
      invoke  Devise::Generators::SharedViewsGenerator
      create    app/views/users/shared
      create    app/views/users/shared/_links.html.erb
      invoke  form_for
      create    app/views/users/confirmations
      create    app/views/users/confirmations/new.html.erb
      create    app/views/users/passwords
      create    app/views/users/passwords/edit.html.erb
      create    app/views/users/passwords/new.html.erb
      create    app/views/users/registrations
      create    app/views/users/registrations/edit.html.erb
      create    app/views/users/registrations/new.html.erb
      create    app/views/users/sessions
      create    app/views/users/sessions/new.html.erb
      create    app/views/users/unlocks
      create    app/views/users/unlocks/new.html.erb
      invoke  erb
      create    app/views/users/mailer
      create    app/views/users/mailer/confirmation_instructions.html.erb
      create    app/views/users/mailer/reset_password_instructions.html.erb
      create    app/views/users/mailer/unlock_instructions.html.erb
```

```
rake db:migrate
== 20150414145341 AddConfirmableToDevise: migrating ===========================
-- add_column(:users, :confirmation_token, :string)
   -> 0.0123s
-- add_column(:users, :confirmed_at, :datetime)
   -> 0.0010s
-- add_column(:users, :confirmation_sent_at, :datetime)
   -> 0.0003s
-- add_index(:users, :confirmation_token, {:unique=>true})
   -> 0.0104s
-- execute("UPDATE users SET confirmed_at = NOW()")
   -> 0.0049s
== 20150414145341 AddConfirmableToDevise: migrated (0.0293s) ==================
```

ここまででrails s 再起動, sign_upするも, e-mail送信前にログインした...
modelで書き忘れに気づく.

```
@@ -2,5 +2,5 @@ class User < ActiveRecord::Base
   # Include default devise modules. Others available are:
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable,
-         :recoverable, :rememberable, :trackable, :validatable, :registerable
+         :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
 end
```

ここで実行 -> error

```
undefined local variable or method `unconfirmed_email' for #<User:0x007f96d11d5b90>
```

それっぽいところを変えてみる.

```
git diff config/
diff --git a/config/initializers/devise.rb b/config/initializers/devise.rb
index 17a1e0e..c131fe7 100644
--- a/config/initializers/devise.rb
+++ b/config/initializers/devise.rb
@@ -11,7 +11,8 @@ Devise.setup do |config|
   # Configure the e-mail address which will be shown in Devise::Mailer,
   # note that it will be overwritten if you use your own mailer class
   # with default "from" parameter.
-  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
+  # config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
+  config.mailer_sender = ENV['EMAIL_SENDER']

   # Configure the class responsible to send e-mails.
   # config.mailer = 'Devise::Mailer'
```

ダメだった. 同じエラー

[issue](https://github.com/JumpstartLab/curriculum/issues/490)にそれっぽいの発見.

`add_column :users, :unconfirmed_email, :string # Only if using reconfirmable`
が必要らしいが, どうすればreconfirmableを無効にできるのか不明.
とりあえずmigrateする.

```sh
be rails g migration add_unconfirmed_email_to_user
```

```
# db/migrate/20150414154550_add_unconfirmed_email_to_user.rb

class AddUnconfirmedEmailToUser < ActiveRecord::Migration
  # Note: You can't use change, as User.update_all will fail in the down migration
  def up
    add_column :users, :unconfirmed_email, :string # Only if using reconfirmable
  end

  def down
    remove_columns :users, :unconfirmed_email # Only if using reconfirmable
  end
end
```

```sh
rake db:migrate
```

rails s 再起動.
さっきまでのエラーは解消.
しかし, メールが送れないらしい.

```
execution expired

 def tcp_socket(address, port)
    TCPSocket.open address, port # ここでエラー
 end
```

ログを見ると, メール本文の作成はできてる.
stnで送信できてないみたい.
環境変数でstnのドメインをミス. -> `~/.zshrc.local`を修正.
まだだめ.

2014のアプリ設定で, `config/initializers/environments/development.rb`を見たら, 根本的に設定が違う.

```
	#メールの設定をする (技大内より技大smtpをたたく)
  config.action_mailer.delivery_method = :smtp
	config.action_mailer.smtp_settings = {
		:address => "stn.nagaokaut.ac.jp",
		:port => 465,
		#:domain => 'nagaokaut.ac.jp',
		:user_name => "s+学籍番号",
		:password => "パスワード",
		#:authentication => 'plain',
		:authentication       => :login,
		:ssl                  => true,
		:tls                  => true,
		:enable_starttls_auto => true,
	}
```

これを元に編集しないと...

とりあえずここまでcommit: `67ad96c`

`config/secrets.yml`を書き換え, 環境変数をセットしたが, なぜか

```sh
bendle exec rails c

irb(main):001:0> Rails.application.secrets
# と
irb(main):001:0> ENV['SMTP_AUTH']
# 等の値が違う...
```

原因不明だが, tmuxのセッションをkillして, 端末を閉じたら同一のものに戻った.
> 後日やったら端末再起動でもダメかも.

パスワードの再設定メールを送ろうとするが, やはり送れない...

とりあえず以前確認したgmailアカウントから, 学外よりパスワードリセットを掛けた.

```
Devise::Mailer#reset_password_instructions: processed outbound mail in 296.9ms

Sent mail to アカウント@gmail.com (39469.1ms)
Date: Wed, 15 Apr 2015 05:09:53 +0900
From: please-change-me-at-config-initializers-devise@example.com
Reply-To: please-change-me-at-config-initializers-devise@example.com
To: アカウント@gmail.com
Message-ID: <552d7411dab0c_3553fe7040832f4942ac@yyamnk-mbp.mail>
Subject: Reset password instructions
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8
Content-Transfer-Encoding: 7bit

<p>Hello アカウント@gmail.com!</p>

<p>Someone has requested a link to change your password. You can do this through the link below.</p>

<p><a href="http://localhost:3000/admin/password/edit?reset_password_token=dkm8fJkASYaABRv1VbwQ">Change my password</a></p>

<p>If you didn't request this, please ignore this email.</p>
<p>Your password won't change until you access the link above and create a new one.</p>

Redirected to http://localhost:3000/admin/login
Completed 302 Found in 40034ms (ActiveRecord: 4.6ms)
```

Form, Reply-To:がおかしいけど, とりあえず送れた!

続いて`sign_up`でも送れた!


ここまで: `80a061c`


# メール送信のテストをrails-consolからやる

```
irb(main):006:0> ActionMailer::Base.mail(to: "アカウント@gmail.com", subject: "題名", body: "本文", from: "アカウント@gmail.com").deliver
DEPRECATION WARNING: `#deliver` is deprecated and will be removed in Rails 5. Use `#deliver_now` to deliver immediately or `#deliver_later` to deliver through Active Job. (called from irb_binding at (irb):6)

ActionMailer::Base#mail: processed outbound mail in 239.5ms

Sent mail to アカウント@gmail.com (6628.4ms)
Date: Wed, 15 Apr 2015 05:21:44 +0900
From: アカウント@gmail.com
To: アカウント@gmail.com
Message-ID: <552d76d8ae04a_5223fe3508602042822c@yyamnk-mbp.mail>
Subject: =?UTF-8?Q?=E9=A1=8C=E5=90=8D?=
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: base64

5pys5paH

=> #<Mail::Message:70245596244060, Multipart: false, Headers: <Date: Wed, 15 Apr 2015 05:21:44 +0900>, <From: アカウント@gmail.com>, <To: アカウント@gmail.com>, <Message-ID: <552d76d8ae04a_5223fe3508602042822c@yyamnk-mbp.mail>>, <Subject: 題名>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: base64>>
```

こっちはfrom入ってるね, たぶんパラメータ渡したから.



# stnからメール送信できた

```
Loading development environment (Rails 4.2.1)
irb(main):001:0> Rails.application.secrets

=> {:secret_key_base=>"40ab42d9149fffa5274b0de78ac82b521ff5aac1004a132a8a3e46cfa495a6a7849f496bf17bc7f3a7eb0c97a128d0393e07be5a18f61a8b77edcc6b84f1e322", :smtp_adress=>"stn.nagaokaut.ac.jp", :smtp_port=>465, :domain_name=>"stn.nagaokaut.ac.jp", :smtp_auth=>"plain", :email_username=>"s103224", :email_password=>"7k7u10is", :secret_token=>nil}

irb(main):002:0> ActionMailer::Base.mail(to: "アカウント@gmail.com", subject: "題名", body: "本文", from: "アカウント@stn.nagaokaut.ac.jp").deliver

DEPRECATION WARNING: `#deliver` is deprecated and will be removed in Rails 5. Use `#deliver_now` to deliver immediately or `#deliver_later` to deliver through Active Job. (called from irb_binding at (irb):2)

ActionMailer::Base#mail: processed outbound mail in 202.1ms

Sent mail to アカウント@gmail.com (161.7ms)
Date: Wed, 15 Apr 2015 21:51:57 +0900
From: アカウント@stn.nagaokaut.ac.jp
To: アカウント@gmail.com
Message-ID: <552e5eed6997e_13a63fdea186020889271@yyamnk-mbp.mail>
Subject: =?UTF-8?Q?=E9=A1=8C=E5=90=8D?=
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: base64

5pys5paH

=> #<Mail::Message:70225479866760, Multipart: false, Headers: <Date: Wed, 15 Apr 2015 21:51:57 +0900>, <From: アカウント@stn.nagaokaut.ac.jp>, <To: アカウント@gmail.com>, <Message-ID: <552e5eed6997e_13a63fdea186020889271@yyamnk-mbp.mail>>, <Subject: 題名>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: base64>>
irb(main):003:0>
```

送れました.

変更した設定

```
diff --git a/config/environments/development.rb b/config/environments/development.rb
index 88ac54d..fb945ef 100644
--- a/config/environments/development.rb
+++ b/config/environments/development.rb
@@ -54,7 +54,9 @@ Rails.application.configure do
       authentication: Rails.application.secrets.smtp_auth,
       enable_starttls_auto: true,
       user_name: Rails.application.secrets.email_username,
-      password: Rails.application.secrets.email_password
+      password: Rails.application.secrets.email_password,
+      authentication: :login,
+      tls: true
     }
```   

tls: trueか, :loginにしたのがいいのか...
どうもstnはtlsで認証しているみたい.



# stnのメール送信を環境変数で対応する

* `tls: true`を削除 -> time out
* `authentication: :login,`を削除 -> 送信可

`tls: true`, `authentication: plain`だけいれればよい.

ここまで: `3266575`


# メール送信者の変更

```
diff --git a/config/initializers/devise.rb b/config/initializers/devise.rb
index 3f9b067..c131fe7 100644
--- a/config/initializers/devise.rb
+++ b/config/initializers/devise.rb
@@ -11,8 +11,8 @@ Devise.setup do |config|
   # Configure the e-mail address which will be shown in Devise::Mailer,
   # note that it will be overwritten if you use your own mailer class
   # with default "from" parameter.
-  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
-  # config.mailer_sender = ENV['EMAIL_SENDER']
+  # config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'
+  config.mailer_sender = ENV['EMAIL_SENDER']
```

追加した環境変数

```
export EMAIL_SENDER='yyamnk <アカウント@stn.nagaokaut.ac.jp>'
```

これで送信者名が入った.

2015-Apr-16, 3:57追記: gmailからも送信できた. senderも正しく設定されていた.

# ログイン後にインデックスページへ飛ばす

ページを作る.

```sh
mkdir app/views/welcome/
```

```
<!-- app/views/welcome/index.html.erb -->

<h1>Wellcome to 技大祭</h1>

<p>技大祭の登録ページへようこそ！</p>
<p>このページでは技大祭へ参加するみなさまに必要な各種申請が可能です。</p>
```

```sh
bundle exec rails g controller welcome index
      create  app/controllers/welcome_controller.rb
       route  get 'welcome/index'
      invoke  erb
      create    app/views/welcome
      create    app/views/welcome/index.html.erb
      invoke  helper
      create    app/helpers/welcome_helper.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/welcome.coffee
      invoke    scss
      create      app/assets/stylesheets/welcome.scss
```

```
git diff config/routes.rb
@@ -1,11 +1,13 @@
 Rails.application.routes.draw do
+  get 'welcome/index'
+
   devise_for :users, ActiveAdmin::Devise.config
   ActiveAdmin.routes(self)
   # The priority is based upon order of creation: first created -> highest priority.
   # See how all your routes lay out with "rake routes".

   # You can have the root of your site routed with "root"
-  # root 'welcome#index'
+  root 'welcome#index'
```

変わらない...

[参考](http://morizyun.github.io/blog/devise-customize-login-register-path/)

気づいた.[ほぼ所望の仕様で構築した記録](http://morizyun.github.io/blog/devise-cancan-rails-authorize/)がある.
なんということ.

気を取り直してログイン後のリダイレクト先を変更する.

```
git diff app/controllers/
--- a/app/controllers/application_controller.rb
+++ b/app/controllers/application_controller.rb
@@ -2,4 +2,16 @@ class ApplicationController < ActionController::Base
   # Prevent CSRF attacks by raising an exception.
   # For APIs, you may want to use :null_session instead.
   protect_from_forgery with: :exception
+
+  #サインイン後の遷移先
+  def after_sign_in_path_for(resource)
+    welcome_index_path
+    # rake routesの<prefix>_pathで飛ぶ.
+    # root_pathはダメだった.
+  end
+
+  #ログアウト後の遷移先
+  def after_sign_out_path_for(resource)
+    admin_root_path
+  end
 end
```

ログイン後に`welcome/index`, ログアウト後に`adimn/login`へ遷移した.

ここまで: `dd24f70`

# userにroleを追加

roleモデルを作って, userモデルにrole_idを追加.
[devise公式wiki](https://github.com/plataformatec/devise/wiki/How-To:-Add-a-default-role-to-a-User)を参考にする

```sh
bundle exec rails g model Role name:string 
      invoke  active_record
      create    db/migrate/20150415172931_create_roles.rb
      create    app/models/role.rb
bundle exec rails g migration addRoleIdToUser role:references
      invoke  active_record
      create    db/migrate/20150415173100_add_role_id_to_user.rb
rake db:migrate

== 20150415171958 AddRoleToUsers: migrating ===================================
-- add_column(:users, :role, :string)
   -> 0.0009s
== 20150415171958 AddRoleToUsers: migrated (0.0011s) ==========================

== 20150415172931 CreateRoles: migrating ======================================
-- create_table(:roles)
   -> 0.0174s
== 20150415172931 CreateRoles: migrated (0.0174s) =============================

== 20150415173100 AddRoleIdToUser: migrating ==================================
-- add_reference(:users, :role, {:index=>true, :foreign_key=>true})
   -> 0.0134s
== 20150415173100 AddRoleIdToUser: migrated (0.0135s) =========================
```

もでるに依存関係を追加

```
git diff HEAD --cached app/models

diff --git a/app/models/role.rb b/app/models/role.rb
new file mode 100644
index 0000000..db68828
--- /dev/null
+++ b/app/models/role.rb
@@ -0,0 +1,3 @@
+class Role < ActiveRecord::Base
+  has_many :users
+end

diff --git a/app/models/user.rb b/app/models/user.rb
index 24c2dcf..0d39e47 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -3,4 +3,5 @@ class User < ActiveRecord::Base
   # :confirmable, :lockable, :timeoutable and :omniauthable
   devise :database_authenticatable,
          :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
+  belongs_to :role
 end
```

Roleモデルにレコードを入れる.
gemを入れるのが面倒なので, 手動で

```
irb(main):002:0> Role.all
  Role Load (0.4ms)  SELECT "roles".* FROM "roles"
=> #<ActiveRecord::Relation []>
irb(main):003:0> dev=Role.new(name: 'developer')
=> #<Role id: nil, name: "developer", created_at: nil, updated_at: nil>
irb(main):004:0> dev.save
   (0.2ms)  BEGIN
  SQL (0.4ms)  INSERT INTO "roles" ("name", "created_at", "updated_at") VALUES ($1, $2, $3) RETURNING "id"  [["name", "developer"], ["created_at", "2015-04-15 17:50:02.964745"], ["updated_at", "2015-04-15 17:50:02.964745"]]
   (0.8ms)  COMMIT
=> true
irb(main):005:0> mane=Role.new( name: 'manager' )
=> #<Role id: nil, name: "manager", created_at: nil, updated_at: nil>
irb(main):006:0> mane.save
   (0.2ms)  BEGIN
  SQL (0.2ms)  INSERT INTO "roles" ("name", "created_at", "updated_at") VALUES ($1, $2, $3) RETURNING "id"  [["name", "manager"], ["created_at", "2015-04-15 17:50:50.854959"], ["updated_at", "2015-04-15 17:50:50.854959"]]
   (0.8ms)  COMMIT
=> true
irb(main):007:0> user=Role.new( name: 'user' )
=> #<Role id: nil, name: "user", created_at: nil, updated_at: nil>
irb(main):008:0> user.save
   (0.3ms)  BEGIN
  SQL (0.3ms)  INSERT INTO "roles" ("name", "created_at", "updated_at") VALUES ($1, $2, $3) RETURNING "id"  [["name", "user"], ["created_at", "2015-04-15 17:51:38.693568"], ["updated_at", "2015-04-15 17:51:38.693568"]]
   (0.8ms)  COMMIT
=> true
irb(main):009:0> Role.all
  Role Load (0.3ms)  SELECT "roles".* FROM "roles"
=> #<ActiveRecord::Relation [#<Role id: 1, name: "developer", created_at: "2015-04-15 17:50:02", updated_at: "2015-04-15 17:50:02">, #<Role id: 2, name: "manager", created_at: "2015-04-15 17:50:50", updated_at: "2015-04-15 17:50:50">, #<Role id: 3, name: "user", created_at: "2015-04-15 17:51:38", updated_at: "2015-04-15 17:51:38">]>
```

制御したいがcancancanを使うのがいいみたい.
[qiita記事](http://qiita.com/umanoda/items/679419ce30d1996628ed)で勉強する.


# cancancan導入

```
gem 'cancancan'
```

```sh
bundle install
bundle exec rails g cancan:ability
      create  app/models/ability.rb
```

テストのため, 既存のUserレコードにroleを設定する

```
irb(main):031:0> user = User.find(2)
irb(main):032:0> user.email
=> "アカウント@gmail.com"
irb(main):033:0> user.role
=> nil
irb(main):034:0> user.role_id
=> nil
irb(main):035:0> user.role_id = 1 #
=> 1
irb(main):036:0> user.save # 更新した
```

今のRoleはこんな感じ

```
irb(main):040:0> Role.all
  Role Load (0.3ms)  SELECT "roles".* FROM "roles"
=> #<ActiveRecord::Relation [#<Role id: 1, name: "developer", created_at: "2015-04-15 17:50:02", updated_at: "2015-04-15 17:50:02">, #<Role id: 2, name: "manager", created_at: "2015-04-15 17:50:50", updated_at: "2015-04-15 17:50:50">, #<Role id: 3, name: "user", created_at: "2015-04-15 17:51:38", updated_at: "2015-04-15 17:51:38">]>
```

これでuserからroleにアクセスできる.

```
irb(main):043:0> user = User.find(2)
irb(main):044:0> user.role
  Role Load (0.3ms)  SELECT  "roles".* FROM "roles" WHERE "roles"."id" = $1 LIMIT 1  [["id", 1]]
=> #<Role id: 1, name: "developer", created_at: "2015-04-15 17:50:02", updated_at: "2015-04-15 17:50:02">
irb(main):045:0> user.role.name
=> "developer"
```

ActiveAdminでuserのroleを編集可能にする

```
git diff app/admin/
diff --git a/app/admin/user.rb b/app/admin/user.rb
index c9b8ee7..eefb6ef 100644
--- a/app/admin/user.rb
+++ b/app/admin/user.rb
@@ -1,10 +1,11 @@
 ActiveAdmin.register User do
-  permit_params :email, :password, :password_confirmation
+  permit_params :email, :password, :password_confirmation, :role

   index do
     selectable_column
     id_column
     column :email
+    column :role
     column :current_sign_in_at
     column :sign_in_count
     column :created_at
@@ -21,6 +22,7 @@ ActiveAdmin.register User do
       f.input :email
       f.input :password
       f.input :password_confirmation
+      f.input :role
     end
     f.actions
   end
```

これでActiveAdminのUser画面にroleの設定項目が追加される.


cancanの権限管理とActiveAdminを連携させる.

[Using the cancan adapter](http://activeadmin.info/docs/13-authorization-adapter.html#using-the-cancan-adapter)
を参考に設定する.

```
% git diff config/
diff --git a/config/initializers/active_admin.rb b/config/initializers/active_admin.rb
index a9b9746..404eeb2 100644
--- a/config/initializers/active_admin.rb
+++ b/config/initializers/active_admin.rb
@@ -62,7 +62,7 @@ ActiveAdmin.setup do |config|
   # method in a before filter of all controller actions to
   # ensure that there is a user with proper rights. You can use
   # CanCanAdapter or make your own. Please refer to documentation.
-  # config.authorization_adapter = ActiveAdmin::CanCanAdapter
+  config.authorization_adapter = ActiveAdmin::CanCanAdapter
```

abilityクラスを編集

```
class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)
    can :read, ActiveAdmin::Page, :name => "Dashboard" # default permission, Dashboardは読める

    if user.role.id = 1 then # for developer
      can :manage, :all
    end
    if user.role.id = 2 then # for manager
      can :read, ActiveAdmin::Page, :name => "User"
    end
    if user.role.id = 3 then # for user
      can :read, ActiveAdmin::Page, :name => "User"
    end
  end

end
```

`User.find(8).role.id => 3`を使って管理画面から新規userが作成できてしまった.
しかし, updateでは更新されていないみたい.
いまいち...

ActiveAdminをcancancanで制御できてない.

# cancancanの制御を確認する

[参考](https://github.com/CanCanCommunity/cancancan/wiki/Debugging-Abilities)

各メソッド確認には`Ability.can?`が暗黙的に実行されているらしい.
`Ability::inittalize`で指定されていない場合は`Ability.can`は`true`を返す

```
class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)

    if user.role.id = 1 then # for developer
      can :manage, :all
    end
    if user.role.id = 3 then # for user
      can :read, User
      cannot :create, User
    end

  end

end
```

でテストすると,

```
% bundle exec rails c --sandbox 
Loading development environment in sandbox (Rails 4.2.1)
Any modifications you make will be rolled back on exit
irb(main):001:0> user = User.third
irb(main):009:0> user.role_id
=> 3
irb(main):002:0> ab = Ability.new( user )
irb(main):003:0> ab.can?( :create, :all )
=> false # ok
irb(main):004:0> ab.can?( :read, :all )
=> true # ok
irb(main):005:0> ab.can?( :update, :all )
=> true # (゜o゜;
irb(main):008:0> ab.can?( :manage, User )
=> true # ( ﾟдﾟ)
```

になってまずい.
if 構文のミスだった.

```
class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)

    if user.role_id == 1 then # for developer
      can :manage, :all
    end

    if user.role_id == 3 then # for user
      can :read, :all
    end

  end

end
```

にすれば

```
% bundle exec rails c --sandbox
Loading development environment in sandbox (Rails 4.2.1)
Any modifications you make will be rolled back on exit
irb(main):003:0> dev = User.where( role_id: 1 ).first
irb(main):004:0> abd = Ability.new( dev )
irb(main):005:0> abd.can?( :manage, :all )
=> true
irb(main):006:0> user = User.where( role_id: 2 ).first
irb(main):010:0> user = User.where( role_id: 3 ).first
irb(main):011:0> abu = Ability.new( user )
irb(main):012:0> abu.can?( :read, :all )
=> true
```

でok.

`http://localhost:3000/admin/users`でユーザによってactionが変わっていることを確認した.

ここまで: `3b4516b`

# ActiveAdminでroleを設定できるようにする

ActiveAdminでUserレコードの新規作成, 更新するとroleが設定されていない.
permit_paramsの設定ミスだった.

```
diff --git a/app/admin/user.rb b/app/admin/user.rb
index eefb6ef..2306554 100644
--- a/app/admin/user.rb
+++ b/app/admin/user.rb
@@ -1,5 +1,5 @@
 ActiveAdmin.register User do
-  permit_params :email, :password, :password_confirmation, :role
+  permit_params :email, :password, :password_confirmation, :role_id
```

で更新出来た.

ここまで: `feb779d`

# Userモデルをパスワード無しで変更する(準備)

ActiveAdminでrole等を変更するのにパスワードが必要.
これをパスワード無しで変更できるようにしたい.

[参考](http://hir-aik.hatenablog.com/entry/2014/09/30/191628),
[wiki](https://github.com/plataformatec/devise/wiki/How-To%3a-Allow-users-to-edit-their-account-without-providing-a-password)を参考にする.

コントローラーを作成

```
# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    super # 動作確認用, オーバーライドされたメソッドを読むのみ
    # resource.update_without_current_password(params)
  end
end
```

ルーティングの設定で詰まった.

```
Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: 'registrations' }
  devise_for :users, ActiveAdmin::Devise.config

end
```

を共存できなかったが, [ココ](http://stackoverflow.com/questions/19537243/routingerror-after-upgrading-activeadmin-to-v-0-6-2)を参考にして変更.

```
diff --git a/config/routes.rb b/config/routes.rb
index cb198d4..ccc024f 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -1,7 +1,11 @@
 Rails.application.routes.draw do
   get 'welcome/index'

-  devise_for :users, ActiveAdmin::Devise.config
+  # deviseのコントローラーをoverrideしたい.
+  # ActiveAdmin::Devise.configを上書きする
+  config = ActiveAdmin::Devise.config
+  config[:controllers][:registrations] = 'registrations'
+  devise_for :users, config
```

```
% rake routes
... 略
cancel_user_registration GET        /admin/cancel(.:format)             registrations#cancel
       user_registration POST       /admin(.:format)                    registrations#create
   new_user_registration GET        /admin/sign_up(.:format)            registrations#new
  edit_user_registration GET        /admin/edit(.:format)               registrations#edit
                         PATCH      /admin(.:format)                    registrations#update
                         PUT        /admin(.:format)                    registrations#update
                         DELETE     /admin(.:format)                    registrations#destroy
... 略
```

これでオーバーライドしたコントローラーを使えるようになった.

新規ユーザはroleがnilのため, cancancanで弾かれる & ルーティングエラーを起こした.
ActiveAdminのセットアップを変更し, active_admin配下へ許可されていないユーザがアクセスした場合の遷移先を設定

ここまで: `e22060d`

#Userモデルをパスワード無しで変更する

参考ページに従って変更した: `ac9c63b`

結局, ActiveAdminではパスワードが求められた.
`app/admin/user.rb`からpasswordの要素を削除すればいいとわかった.
ActiveAdmin経由の更新はdeviseのコントローラーではないみたい.

app/controllers/registrations_controller.rbはデフォルトのroleを設定するのに使う.


# roleのデフォルトを設定する

```
git checkout HEAD^^ app/models/user.rb

% git diff app/models/user.rb
diff --git a/app/models/user.rb b/app/models/user.rb
index 0923b55..ec883ca 100644
--- a/app/models/user.rb
+++ b/app/models/user.rb
@@ -5,4 +5,11 @@ class User < ActiveRecord::Base
          :recoverable, :rememberable, :trackable, :validatable, :registerable, :confirmable
   belongs_to :role # Userからroleを参照可能にする, ex) User.find(1).role

+  before_create :set_default_role
+
+  private
+
+  def set_default_role
+    self.role_id ||= Role.find(3).id  #デフォルトのRole.id
+  end
 end
```

これでデフォルトのroleがid=3の'user'になった.

サインイン後の遷移がおかしい.

[ここ](https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-up-(registration))を参考に修正

```
diff --git a/app/controllers/registrations_controller.rb b/app/controllers/registrations_controller.rb
index 4ff8c55..00c54c0 100644
--- a/app/controllers/registrations_controller.rb
+++ b/app/controllers/registrations_controller.rb
@@ -1,9 +1,9 @@
 class RegistrationsController < Devise::RegistrationsController

-  protected
-
-  def update_resource(resource, params)
-    # super # 動作確認用, オーバーライドされたメソッドを読むのみ
-    resource.update_without_current_password(params) # Userモデルで実装する
+  # ref
+  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-on-successful-sign-up-(registration)
+  def after_inactive_sign_up_path_for(resource) # サインアップしたけどメール認証が終わってない場合
+    # '/an/example/path'
+    '/admin/login'
   end
 end
```

ここまで: `0cb64de`

#ActionMailerでe-mail送信時にbccを追加

[これのままやる](http://qiita.com/ytr_i/items/ae0b5bad96e23599b45f)
bccのテストしてない...

ここまで: `dfa7fd7`

#アプリ名変更

```
diff --git a/config/application.rb b/config/application.rb
index 6b7c54f..1590328 100644
--- a/config/application.rb
+++ b/config/application.rb
@@ -15,7 +15,7 @@ require "sprockets/railtie"
 # you've limited to :test, :development, or :production.
 Bundler.require(*Rails.groups)

-module TestAdminPermission
+module SampleAdminRoles
   class Application < Rails::Application
     # Settings in config/environments/* take precedence over those specified here.
     # Application configuration should go into files in config/initializers

diff --git a/config/initializers/active_admin.rb b/config/initializers/active_admin.rb
index 61e955a..5519130 100644
--- a/config/initializers/active_admin.rb
+++ b/config/initializers/active_admin.rb
@@ -4,7 +4,7 @@ ActiveAdmin.setup do |config|
   # Set the title that is displayed on the main layout
   # for each of the active admin pages.
   #
-  config.site_title = "Test Admin Permission"
+  config.site_title = "Sample Admin Roles"

   # Set the link url for the title. For example, to take
   # users to your main site. Defaults to no link.

diff --git a/config/initializers/session_store.rb b/config/initializers/session_store.rb
index 9900356..beda81a 100644
--- a/config/initializers/session_store.rb
+++ b/config/initializers/session_store.rb
@@ -1,3 +1,3 @@
 # Be sure to restart your server when you modify this file.

-Rails.application.config.session_store :cookie_store, key: '_test_admin_permission_session'
+Rails.application.config.session_store :cookie_store, key: '_sample_admin_roles_session'
```

# アプリのlocaleを変更

deviseを簡単に日本語化できるgemがあったので導入.

```
# Gemfile

+gem 'devise-i18n'
```

```
bundle
```

アプリのlocaleを変更

```
diff --git a/config/application.rb b/config/application.rb
index 1590328..3c546f3 100644
--- a/config/application.rb
+++ b/config/application.rb
@@ -28,6 +28,7 @@ module SampleAdminRoles
     # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
     # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
     # config.i18n.default_locale = :de
+    config.i18n.default_locale = :ja
```

このままだとActiveAdminで辞書ファイルがなくて怒られるので.
ActiveAdminのlocaleは`en`にする

```
diff --git a/config/initializers/active_admin.rb b/config/initializers/active_admin.rb
index 5519130..95eb2d2 100644
--- a/config/initializers/active_admin.rb
+++ b/config/initializers/active_admin.rb
@@ -139,6 +139,11 @@ ActiveAdmin.setup do |config|
   # Active Admin resources and pages from here.
   #
   # config.before_filter :do_something_awesome
+  #
+  # ActiveAdminではenに固定,
+  config.before_filter do
+    I18n.locale = 'en'
+  end
```

# Userの詳細情報を追加

UserDetailモデルを追加し, Userモデルと関連付ける.

初期データを流し込むために`seed-fu`を追加

```
# Gemfileへ
gem 'seed-fu', '~> 2.3'
```

```
bundle
```

## 先に所属コースモデルを作る.

```
bundle exec rails g model Department name_ja:string name_en:string
```

``` 
# db/fixtures/department.rb
# 所属コース初期値
Department.seed( :id,
  { id: 1  , name_ja: '[学部]配属前' }                     ,
  { id: 2  , name_ja: '[学部]機械創造工学課程' }           ,
  { id: 3  , name_ja: '[学部]電気電子情報工学課程' }       ,
  { id: 4  , name_ja: '[学部]材料開発工学課程' }           ,
  { id: 5  , name_ja: '[学部]建設工学課程' }               ,
  { id: 6  , name_ja: '[学部]環境システム工学課程' }       ,
  { id: 7  , name_ja: '[学部]生物機能工学課程' }           ,
  { id: 8  , name_ja: '[学部]経営情報システム工学課程' }   ,
  { id: 9  , name_ja: '[修士]機械創造工学専攻' }           ,
  { id: 10 , name_ja: '[修士]電気電子情報工学専攻' }       ,
  { id: 11 , name_ja: '[修士]材料開発工学専攻' }           ,
  { id: 12 , name_ja: '[修士]建設工学専攻' }               ,
  { id: 13 , name_ja: '[修士]環境システム工学専攻' }       ,
  { id: 14 , name_ja: '[修士]生物機能工学専攻' }           ,
  { id: 15 , name_ja: '[修士]経営情報システム工学専攻' }   ,
  { id: 16 , name_ja: '[修士]原子力システム安全工学専攻' } ,
  { id: 17 , name_ja: '[博士]情報・制御工学専攻' }         ,
  { id: 18 , name_ja: '[博士]材料工学専攻' }               ,
  { id: 19 , name_ja: '[博士]エネルギー・環境工学専攻' }   ,
  { id: 20 , name_ja: '[博士]生物統合工学専攻' }           ,
  { id: 21 , name_ja: '[博士]システム安全専攻' }           ,
  { id: 22 , name_ja: '[他]不明' }
)
```

```sh
rake db:migrate
== 20150421143139 CreateDepartments: migrating ================================
-- create_table(:departments)
   -> 0.0387s
== 20150421143139 CreateDepartments: migrated (0.0388s) =======================

rake db:seed_fu
== Seed from /Volumes/Data/Dropbox/nfes15/sample_admin_roles/db/fixtures/department.rb
 - Department {:id=>1, :name_ja=>"[学部]配属前"}
 - Department {:id=>2, :name_ja=>"[学部]機械創造工学課程"}
 - Department {:id=>3, :name_ja=>"[学部]電気電子情報工学課程"}
 - Department {:id=>4, :name_ja=>"[学部]材料開発工学課程"}
 - Department {:id=>5, :name_ja=>"[学部]建設工学課程"}
 - Department {:id=>6, :name_ja=>"[学部]環境システム工学課程"}
 - Department {:id=>7, :name_ja=>"[学部]生物機能工学課程"}
 - Department {:id=>8, :name_ja=>"[学部]経営情報システム工学課程"}
 - Department {:id=>9, :name_ja=>"[修士]機械創造工学専攻"}
 - Department {:id=>10, :name_ja=>"[修士]電気電子情報工学専攻"}
 - Department {:id=>11, :name_ja=>"[修士]材料開発工学専攻"}
 - Department {:id=>12, :name_ja=>"[修士]建設工学専攻"}
 - Department {:id=>13, :name_ja=>"[修士]環境システム工学専攻"}
 - Department {:id=>14, :name_ja=>"[修士]生物機能工学専攻"}
 - Department {:id=>15, :name_ja=>"[修士]経営情報システム工学専攻"}
 - Department {:id=>16, :name_ja=>"[修士]原子力システム安全工学専攻"}
 - Department {:id=>17, :name_ja=>"[博士]情報・制御工学専攻"}
 - Department {:id=>18, :name_ja=>"[博士]材料工学専攻"}
 - Department {:id=>19, :name_ja=>"[博士]エネルギー・環境工学専攻"}
 - Department {:id=>20, :name_ja=>"[博士]生物統合工学専攻"}
 - Department {:id=>21, :name_ja=>"[博士]システム安全専攻"}
 - Department {:id=>22, :name_ja=>"[他]不明"}
```

ここまで: `b013a49`


## 学年モデルも追加

```
bundle exec rails g model Grade name:string
```

```
# db/fixtures/grade.rb

# 学年の初期値
Grade.seed( :id,
  { id: 1, name: 'B1' },
  { id: 2, name: 'B2' },
  { id: 3, name: 'B3' },
  { id: 4, name: 'B4' },
  { id: 5, name: 'M1' },
  { id: 6, name: 'M2' },
  { id: 7, name: 'D1' },
  { id: 8, name: 'D2' },
  { id: 9, name: 'D3' },
  { id: 10, name: 'その他, other' }
)
```

```
rake db:migrate
== 20150421144117 CreateGrades: migrating =====================================
-- create_table(:grades)
   -> 0.0057s
== 20150421144117 CreateGrades: migrated (0.0058s) ============================

rake db:seed_fu
... 略
== Seed from /Volumes/Data/Dropbox/nfes15/sample_admin_roles/db/fixtures/grade.rb
 - Grade {:id=>1, :name=>"B1"}
 - Grade {:id=>2, :name=>"B2"}
 - Grade {:id=>3, :name=>"B3"}
 - Grade {:id=>4, :name=>"B4"}
 - Grade {:id=>5, :name=>"M1"}
 - Grade {:id=>6, :name=>"M2"}
 - Grade {:id=>7, :name=>"D1"}
 - Grade {:id=>8, :name=>"D2"}
 - Grade {:id=>9, :name=>"D3"}
 - Grade {:id=>10, :name=>"その他, other"}
```

ここまで: `db8d279`

## ユーザ詳細を作成し, Department, Gradeと関連付ける

```sh
% bundle exec rails g scaffold UserDetail name_ja:string name_en:string department:references grade:references tel:string

    invoke  active_record
      create    db/migrate/20150421145814_create_user_details.rb
      create    app/models/user_detail.rb
      invoke  resource_route
       route    resources :user_details
      invoke  inherited_resources_controller
      create    app/controllers/user_details_controller.rb
      invoke    erb
      create      app/views/user_details
      create      app/views/user_details/index.html.erb
      create      app/views/user_details/edit.html.erb
      create      app/views/user_details/show.html.erb
      create      app/views/user_details/new.html.erb
      create      app/views/user_details/_form.html.erb
      invoke    helper
      create      app/helpers/user_details_helper.rb
      invoke    jbuilder
      create      app/views/user_details/index.json.jbuilder
      create      app/views/user_details/show.json.jbuilder
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/user_details.coffee
      invoke    scss
      create      app/assets/stylesheets/user_details.scss
      invoke  scss
   identical    app/assets/stylesheets/scaffolds.scss

% rake db:migrate
== 20150421145814 CreateUserDetails: migrating ================================
-- create_table(:user_details)
   -> 0.0231s
== 20150421145814 CreateUserDetails: migrated (0.0232s) =======================
```

ここまで: `35b6763`

# UserDetailとUserの関連付け

忘れていたので追加する

```
bundle exec rails g migration AddUserIdToUserDetail user:references
      invoke  active_record
      create    db/migrate/20150421150907_add_user_id_to_user_detail.rb

rake db:migrate
== 20150421150907 AddUserIdToUserDetail: migrating ============================
-- add_reference(:user_details, :user, {:index=>true, :foreign_key=>true})
   -> 0.0098s
== 20150421150907 AddUserIdToUserDetail: migrated (0.0098s) ===================
```

# scaffoldで生成するコントローラーを標準へ戻す.

ActiveAdminは`inherited_resouces`でコントローラーを生成する.
そのため, ActiveAdminの導入後は`scaffold`のコントローラーがinherited_resoucesを継承するようになる.
使いにくいので標準へ戻す.

[参考](http://www.codebeerstartups.com/2013/04/how-to-disable-inherited-resources-controller-in-ruby-on-rails)
から

```
diff --git a/config/application.rb b/config/application.rb
index 3c546f3..5138444 100644
--- a/config/application.rb
+++ b/config/application.rb
@@ -32,5 +32,8 @@ module SampleAdminRoles

     # Do not swallow errors in after_commit/after_rollback callbacks.
     config.active_record.raise_in_transactional_callbacks = true
+
+    # scaffoldで生成するコントローラーにinherited_resoucesを継承させない
+    config.app_generators.scaffold_controller = :scaffold_controller
   end
 end
```

ロールバックをかける

```
rake db:rollback
== 20150421150907 AddUserIdToUserDetail: reverting ============================
-- remove_reference(:user_details, :user, {:index=>true, :foreign_key=>true})
   -> 0.0136s
== 20150421150907 AddUserIdToUserDetail: reverted (0.0162s) ===================

rake db:rollback
== 20150421145814 CreateUserDetails: reverting ================================
-- drop_table(:user_details)
   -> 0.0047s
== 20150421145814 CreateUserDetails: reverted (0.0078s) =======================
```

```
# マイグレーションを削除
bundle exec rails destroy migration AddUserIdToUserDetail
      invoke  active_record
      remove    db/migrate/20150421150907_add_user_id_to_user_detail.rb

# scaffoldを取り消す
bundle exec rails destroy scaffold UserDetail

# 再度scaffold, userとの紐付けもやる
bundle exec rails g scaffold UserDetail user:references name_ja:string name_en:string department:references grade:references tel:string
      invoke  active_record
      create    db/migrate/20150421154159_create_user_details.rb
      create    app/models/user_detail.rb
      invoke  resource_route
       route    resources :user_details
      invoke  scaffold_controller
      create    app/controllers/user_details_controller.rb
      invoke    erb
      create      app/views/user_details
      create      app/views/user_details/index.html.erb
      create      app/views/user_details/edit.html.erb
      create      app/views/user_details/show.html.erb
      create      app/views/user_details/new.html.erb
      create      app/views/user_details/_form.html.erb
      invoke    helper
      create      app/helpers/user_details_helper.rb
      invoke    jbuilder
      create      app/views/user_details/index.json.jbuilder
      create      app/views/user_details/show.json.jbuilder
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/user_details.coffee
      invoke    scss
      create      app/assets/stylesheets/user_details.scss
      invoke  scss
   identical    app/assets/stylesheets/scaffolds.scss

rake db:migrate
== 20150421154159 CreateUserDetails: migrating ================================
-- create_table(:user_details)
   -> 0.0239s
== 20150421154159 CreateUserDetails: migrated (0.0240s) =======================
```

ここまで: `222d723`

うーん, viewsを書くのが面倒くさい, ついでにbootstrapを当てれば楽なんじゃないか.

# simple_form + bootstrapを導入する

[多分有名な鉄板サイト](http://www.ohmyenter.com/?p=197)を参考にする.

```
diff --git a/Gemfile b/Gemfile
index 3a4311f..d36cb5c 100644
--- a/Gemfile
+++ b/Gemfile
@@ -52,3 +52,10 @@ gem 'activeadmin', github: 'activeadmin'
 gem 'cancancan', '~> 1.10'
 # 初期データ入力
 gem 'seed-fu', '~> 2.3'
+# viewを簡単に書く
+gem 'simple_form'
+# bootstrap関連
+# twitter-bootstrap-railsはlessを使うので必要
+gem 'therubyracer'
+gem 'less-rails'
+gem 'twitter-bootstrap-rails'
+gem 'simple_form'
```

```
bundle
```

いったんマイグレーションをロールバックして, scaffoldで作成したのを消す.

```
% rake db:rollback
[Simple Form] Simple Form is not configured in the application and will use the default values. Use `rails generate simple_form:install` to generate the Simple Form configuration.
== 20150421154159 CreateUserDetails: reverting ================================
-- drop_table(:user_details)
   -> 0.0117s
== 20150421154159 CreateUserDetails: reverted (0.0145s) =======================

% bundle exec rails destroy scaffold UserDetail
      invoke  active_record
      remove    db/migrate/20150421154159_create_user_details.rb
      remove    app/models/user_detail.rb
      invoke  resource_route
       route    resources :user_details
      invoke  scaffold_controller
      remove    app/controllers/user_details_controller.rb
      invoke    erb
      remove      app/views/user_details
      remove      app/views/user_details/index.html.erb
      remove      app/views/user_details/edit.html.erb
      remove      app/views/user_details/show.html.erb
      remove      app/views/user_details/new.html.erb
      remove      app/views/user_details/_form.html.erb
      invoke    helper
      remove      app/helpers/user_details_helper.rb
      invoke    jbuilder
      remove      app/views/user_details
      remove      app/views/user_details/index.json.jbuilder
      remove      app/views/user_details/show.json.jbuilder
      invoke  assets
      invoke    coffee
      remove      app/assets/javascripts/user_details.coffee
      invoke    scss
      remove      app/assets/stylesheets/user_details.scss
      invoke  scss
```

```
% bundle exec rails g bootstrap:install less
      insert  app/assets/javascripts/application.js
      create  app/assets/javascripts/bootstrap.js.coffee
      create  app/assets/stylesheets/bootstrap_and_overrides.css.less
      create  config/locales/en.bootstrap.yml
        gsub  app/assets/stylesheets/application.css

% bundle exec rails generate simple_form:install --bootstrap
   identical  config/initializers/simple_form.rb
      create  config/initializers/simple_form_bootstrap.rb
       exist  config/locales
   identical  config/locales/simple_form.en.yml
   identical  lib/templates/erb/scaffold/_form.html.erb
===============================================================================

  Be sure to have a copy of the Bootstrap stylesheet available on your
  application, you can get it on http://getbootstrap.com/.

  Inside your views, use the 'simple_form_for' with one of the Bootstrap form
  classes, '.form-horizontal' or '.form-inline', as the following:

    = simple_form_for(@user, html: { class: 'form-horizontal' }) do |form|

===============================================================================
```

マイグレーション忘れてた

```
% rake db:migrate
== 20150421144117 CreateGrades: migrating =====================================
-- create_table(:grades)
   -> 0.0159s
== 20150421144117 CreateGrades: migrated (0.0160s) ============================

== 20150422133839 CreateUserDetails: migrating ================================
-- create_table(:user_details)
   -> 0.0245s
== 20150422133839 CreateUserDetails: migrated (0.0246s) =======================
```

試行錯誤で戻しすぎてたかも( grade作成前までrollbackしてる)

実行してみると, simple_formとbootstrapで作成されているのがわかる.
しかし, 問題は`f.association`で引っ張られる値がハッシュ?っぽくなってる.
`Grade`のレコードも無いみたい.

ここまで: `6be919e`

# Gradeのレコードを再度追加

```
rake db:seed_fu
```

`Grade`のデータは引っ張れてるみたい.
どうも`name`要素を引っ張ってくるようだ.

ここまで: `799b7b5`

# UserDetailのDepartment, Gradeの表示を治す

`_form`, `index`, `show`で該当部分に明示する
```
diff --git a/app/views/user_details/_form.html.erb b/app/views/user_details/_form.html.erb
index 3bfff85..9d68ef9 100644
--- a/app/views/user_details/_form.html.erb
+++ b/app/views/user_details/_form.html.erb
@@ -2,10 +2,10 @@
   <%= f.error_notification %>

   <div class="form-inputs">
-    <%= f.association :user %>
+    <%= f.association :user, label_method: :email%>
     <%= f.input :name_ja %>
     <%= f.input :name_en %>
-    <%= f.association :department %>
+    <%= f.association :department, label_method: :name_ja %>
     <%= f.association :grade %>
     <%= f.input :tel %>
   </div>

diff --git a/app/views/user_details/index.html.erb b/app/views/user_details/index.html.erb
index 49a2fd0..4fc4a89 100644
--- a/app/views/user_details/index.html.erb
+++ b/app/views/user_details/index.html.erb
@@ -18,11 +18,11 @@
   <tbody>
     <% @user_details.each do |user_detail| %>
       <tr>
-        <td><%= user_detail.user %></td>
+        <td><%= user_detail.user.email %></td>
         <td><%= user_detail.name_ja %></td>
         <td><%= user_detail.name_en %></td>
-        <td><%= user_detail.department %></td>
-        <td><%= user_detail.grade %></td>
+        <td><%= user_detail.department.name_ja %></td>
+        <td><%= user_detail.grade.name %></td>
         <td><%= user_detail.tel %></td>
         <td><%= link_to 'Show', user_detail %></td>
         <td><%= link_to 'Edit', edit_user_detail_path(user_detail) %></td>

diff --git a/app/views/user_details/show.html.erb b/app/views/user_details/show.html.erb
index 75dba17..b091eca 100644
--- a/app/views/user_details/show.html.erb
+++ b/app/views/user_details/show.html.erb
@@ -2,7 +2,7 @@

 <p>
   <strong>User:</strong>
-  <%= @user_detail.user %>
+  <%= @user_detail.user.email %>
 </p>

 <p>
@@ -17,12 +17,12 @@

 <p>
   <strong>Department:</strong>
-  <%= @user_detail.department %>
+  <%= @user_detail.department.name_ja %>
 </p>

 <p>
   <strong>Grade:</strong>
-  <%= @user_detail.grade %>
+  <%= @user_detail.grade.name %>
 </p>
```

showにデザインが適用されてないみたい.

ここまで: `2a99869`

# bootstrapのデザインを適用する

```
% bundle exec rails g bootstrap:layout application fluid
    conflict  app/views/layouts/application.html.erb
Overwrite /Volumes/Data/Dropbox/nfes15/sample_admin_roles/app/views/layouts/application.html.erb? (enter "h" for help) [Ynaqdh] Y
       force  app/views/layouts/application.html.erb

% bundle exec rails g bootstrap:themed UserDetails
    conflict  app/views/user_details/index.html.erb
Overwrite /Volumes/Data/Dropbox/nfes15/sample_admin_roles/app/views/user_details/index.html.erb? (enter "h" for help) [Ynaqdh] Y
       force  app/views/user_details/index.html.erb
    conflict  app/views/user_details/new.html.erb
Overwrite /Volumes/Data/Dropbox/nfes15/sample_admin_roles/app/views/user_details/new.html.erb? (enter "h" for help) [Ynaqdh] Y
       force  app/views/user_details/new.html.erb
    conflict  app/views/user_details/edit.html.erb
Overwrite /Volumes/Data/Dropbox/nfes15/sample_admin_roles/app/views/user_details/edit.html.erb? (enter "h" for help) [Ynaqdh] Y
       force  app/views/user_details/edit.html.erb
    conflict  app/views/user_details/_form.html.erb
Overwrite /Volumes/Data/Dropbox/nfes15/sample_admin_roles/app/views/user_details/_form.html.erb? (enter "h" for help) [Ynaqdh] Y
       force  app/views/user_details/_form.html.erb
    conflict  app/views/user_details/show.html.erb
Overwrite /Volumes/Data/Dropbox/nfes15/sample_admin_roles/app/views/user_details/show.html.erb? (enter "h" for help) [Ynaqdh] Y
       force  app/views/user_details/show.html.erb
```

エラー出た.

```
translation missing: ja.time.formats.default
```

デフォルトのlocaleを`ja`にしているため.

```
diff --git a/config/application.rb b/config/application.rb
-    config.i18n.default_locale = :ja
+    # config.i18n.default_locale = :ja
```

にしたら表示できた.
が, ちょっと表示がおかしいかな. 一部でActiveAdminと競合しているみたい.
関連するModelの表示が, またおかしくなった...さっき修正したの全部上書きされたからな...

ここまで: `07b2e16`


# bootstrapで上書きされたsimple_formのviewを修正する

`index`, `show`, `_form`を書き直した.

