class CreateGreensheetTexts < ActiveRecord::Migration
  def change
    create_table :greensheet_texts do |t|
      t.integer :user_id
      t.string :text
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end
