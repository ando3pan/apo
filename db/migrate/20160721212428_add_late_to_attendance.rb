class AddLateToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :late, :boolean
  end
end
