class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name_ja
      t.string :name_en

      t.timestamps null: false
    end
  end
end
