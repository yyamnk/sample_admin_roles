#Sample Admin Roles

ユーザ登録 + アクセス制限 + 管理画面 の実装を目指した試行錯誤の記録

#実装した機能

* 1ユーザ, 1権限
    - UserモデルとRoleモデルを紐付け
* ユーザ登録時 -> `devise`
    - メール送信, URLを踏むと認証完了(メールアドレス確認)
    - デフォルトroleを設定
* 管理画面 -> `ActiveAdmin`
* アクセス, 機能制限 -> `cancancan`

#主なgem

```
gem 'rails', '4.2.1'
gem 'pg'

gem 'devise'
gem 'activeadmin', github: 'activeadmin'
gem 'cancancan', '~> 1.10'
```

#必要な環境変数

```
#Gmailの例
export SMTP_ADRESS=smtp.gmail.com
export SMTP_PORT=587
export EMAIL_DOMAIN=gmail.com
export SMTP_AUTH=plain
export SMTP_TLS=false
export EMAIL_USERNAME=ユーザ@gmail.com
export EMAIL_BCC=sample@example.com'
export EMAIL_PASSWORD=パスワード
export EMAIL_SENDER='送信者名 <ユーザ@gmail.com>'
```

#作業記録

`docs/log.md`
