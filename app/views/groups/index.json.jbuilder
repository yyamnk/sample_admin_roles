json.array!(@groups) do |group|
  json.extract! group, :id, :name, :group_category_id, :user_id, :activity, :first_question
  json.url group_url(group, format: :json)
end
