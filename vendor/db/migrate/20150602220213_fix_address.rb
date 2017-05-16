class FixAddress < ActiveRecord::Migration
  def change
    add_column :events, :address, :string, default: ""
  end
end
