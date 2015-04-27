ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :roles_id

  index do
    selectable_column
    id_column
    column :email
    column :roles_id do |role|
      link_to user.role.name, admin_role_path(role)
    end
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
      f.input :roles_id
    end
    f.actions
  end

end
