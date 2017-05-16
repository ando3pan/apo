class ChangeEventMileageToString < ActiveRecord::Migration
  def change
  	change_column :events, :distance, :string, default: ""
  end
end
