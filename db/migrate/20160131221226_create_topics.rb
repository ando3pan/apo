class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title, null: false, default: ""
      t.integer :creator_id, null: false, default: 0

      t.timestamps null: false
    end
  end
end
