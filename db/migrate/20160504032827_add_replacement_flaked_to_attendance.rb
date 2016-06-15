class AddReplacementFlakedToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :replacement_flaked, :boolean
  end
end
