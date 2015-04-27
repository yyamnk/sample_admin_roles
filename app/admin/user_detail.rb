ActiveAdmin.register UserDetail do
  permit_params :user, :name_ja, :name_en, :tel, :user_id, :grade_id, :department_id
  actions :all, :except => [:destroy] # destory以外はOKにする

  index do
    selectable_column
    id_column
    column :user
    column :name_ja
    column :name_en
    column :grade
    column :department
    column :tel
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :user
      f.input :name_ja
      f.input :name_en
      f.input :grade
      f.input :department
      f.input :tel
    end
    f.actions
  end
end
