class AddEboardToForum < ActiveRecord::Migration
  def change
    add_column :forums, :eboard_only, :boolean, default: false
  end
end
