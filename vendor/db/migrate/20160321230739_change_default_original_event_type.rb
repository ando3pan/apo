class ChangeDefaultOriginalEventType < ActiveRecord::Migration
  def change
    change_column :greensheet_sections, :original_event_type, :string, default: "any"
  end
end
