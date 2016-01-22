class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.datetime :fall_quarter, null: false, default: Time.now
      t.datetime :winter_quarter, null: false, default: Time.now
      t.datetime :spring_quarter, null: false, default: Time.now

      t.timestamps null: false
    end
  end
end
