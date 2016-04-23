class Attendance < ActiveRecord::Base
	belongs_to :user
	belongs_to :event, class_name: "Event" # Use attending_event_id as foreign_key
end
