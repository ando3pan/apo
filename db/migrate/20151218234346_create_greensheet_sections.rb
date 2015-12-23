class CreateGreensheetSections < ActiveRecord::Migration
  def change
    create_table :greensheet_sections do |t|
      t.integer :user_id
      t.string :title
      t.datetime :start_time
      t.decimal :hours, default: 0
      t.string :chair
      t.string :event_type

      t.timestamps null: false
    end
  end
end
