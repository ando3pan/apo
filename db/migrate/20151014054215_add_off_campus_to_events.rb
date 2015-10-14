class AddOffCampusToEvents < ActiveRecord::Migration
  def change
    add_column :events, :off_campus, :boolean, default: false
  end
end
