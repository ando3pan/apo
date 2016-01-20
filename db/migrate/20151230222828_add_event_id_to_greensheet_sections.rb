class AddEventIdToGreensheetSections < ActiveRecord::Migration
  def change
    change_table( :greensheet_sections ) do |t|
      t.integer :event_id, null: false, default: 0
    end
  end
end
