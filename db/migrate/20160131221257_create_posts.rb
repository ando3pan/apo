class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :comment, null: false, default: ""
      t.integer :creator_id, null: false, default: 0

      t.timestamps null: false
    end
  end
end
