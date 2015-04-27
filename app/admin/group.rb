ActiveAdmin.register Group do

  permit_params :user_id, :name, :group_category_id, :activity, :first_question

  index do
    selectable_column
    id_column
    column :user
    column :name
    column :group_category
    column :activity
    column :created_at
    actions
  end

end
