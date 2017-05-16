class AddFieldstoUser < ActiveRecord::Migration
  def change
  	change_table(:users) do |t|
      ## Database authenticatable
      t.string :username,   null: false, default: ""
      t.string :a_username, null: false, default: ""
      t.string :firstname, null: false, default: ""
      t.string :lastname, null: false, default: ""
			t.string :nickname, null: false, default: ""
			t.string :displayname, null: false, default: ""
			t.string :phone, null: false, default: ""
			t.string :family, null: false, default: ""
			t.string :line, null: false, default: ""
			t.string :membership_status, null: false, default: ""
			t.string :pledge_class, null: false, default: ""
			t.string :major, null: false, default: ""
			t.integer :graduation_year, null: false, default: 0
			t.string :shirt_size, null: false, default: ""

			t.date :birthday 
			t.boolean :car, null: false, default: false
    end
  end
end
