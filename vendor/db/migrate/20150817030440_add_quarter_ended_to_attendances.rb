class AddQuarterEndedToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :quarter_ended, :datetime
  end
end
