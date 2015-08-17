class AddEndedToAttendances < ActiveRecord::Migration
  def change
  	add_column :attendances, :past_quarter, :boolean, default: false
  end
end
