class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.integer :user_id #user id
      t.integer :event_id
      t.boolean :attended
      t.boolean :flaked
      t.boolean :chair
      t.boolean :can_drive
      t.boolean :drove

      t.timestamps null: false
    end
    add_index :attendances, :user_id
    add_index :attendances, :event_id
    add_index :attendances, [:user_id, :event_id], unique: true
  end
end
