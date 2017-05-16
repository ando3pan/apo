class AddFieldsToEvent < ActiveRecord::Migration
  def change
  	change_table(:events) do |t|
      ## Database authenticatable
      t.datetime :start_time
      t.datetime :end_time
      t.string   :location
      t.string   :title
      t.string	 :event_type
      t.decimal  :hours, default: 0
      t.decimal  :driver_hours, default: 0
      t.boolean  :flake_penalty, default: true
      t.text		 :info, default: ""
      t.decimal  :distance, default: 0
      t.string	 :contact, default: ""
      t.integer  :attendance_cap
      t.integer  :user_id
      t.boolean  :public, default: true
      t.integer  :chair_id
    end
  end
end
