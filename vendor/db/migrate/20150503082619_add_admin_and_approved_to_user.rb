class AddAdminAndApprovedToUser < ActiveRecord::Migration
  def change
  	change_table(:users) do |t|
      ## Database authenticatable
			t.boolean :admin, null: false, default: false
			t.boolean :approved, null: false, default: false
			t.string  :standing
    end
  end
end
