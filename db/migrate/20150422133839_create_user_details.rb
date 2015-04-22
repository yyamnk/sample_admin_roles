class CreateUserDetails < ActiveRecord::Migration
  def change
    create_table :user_details do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name_ja
      t.string :name_en
      t.references :department, index: true, foreign_key: true
      t.references :grade, index: true, foreign_key: true
      t.string :tel

      t.timestamps null: false
    end
  end
end
