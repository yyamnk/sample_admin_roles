ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :role_id

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :user_detail
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      # パスワードの入力フォームがあると, 常に入力を求められる
      # -> 管理者はuserのパスワード知らない -> 詰む
      # パスワード編集用のページを新しく作るべきかも.
      # f.input :password
      # f.input :password_confirmation
      f.input :role
    end
    f.actions
  end

end
