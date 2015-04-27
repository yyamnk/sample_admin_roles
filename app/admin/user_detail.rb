ActiveAdmin.register UserDetail do

  actions :all, :except => [:destroy] # destory以外はOKにする

  index do
    selectable_column
    id_column
    column :name_ja do |detail|
      link_to detail.name_ja, admin_user_path(detail.user_id)
    end
    column :name_en do |detail|
      link_to detail.name_en, admin_user_path(detail.user_id)
    end
    column :grade
    column :department
    column :tel
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      # f.input :user_id, collection: User.all
      # f.input :user, collection: User.all.select( :email, :id)
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
