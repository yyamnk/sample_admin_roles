class CreateGroupCategories < ActiveRecord::Migration
  def change
    create_table :group_categories do |t|
      t.string :name_ja
      t.string :name_en

      t.timestamps null: false
    end
  end
end
