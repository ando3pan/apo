class AddOriginalEventTypeToGreensheetSection < ActiveRecord::Migration
  def change
    change_table(:greensheet_sections) do |t|
      t.string :original_event_type, null: false, default: ""
    end
  end
end
