class ChangeOffCampusToDefaultTrue < ActiveRecord::Migration
  def change
    change_column :events, :off_campus, :boolean, default: true
  end
end
