class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.string :title, null: false, default: ""
      t.string :description, null: false, default: ""
      t.integer :creator_id, null: false, default: 0

      t.timestamps null: false
    end
  end
end
