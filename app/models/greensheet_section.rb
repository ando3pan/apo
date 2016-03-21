class GreensheetSection < ActiveRecord::Base
belongs_to :user
validates :title, :start_time, :event_type, :hours, :chair, presence: true

  def self.calculateHours(attendance, event)
    return 0 if !attendance.attended
    hours = event.hours
    unless attendance.flaked
      hours = event.driver_hours if attendance.drove
    end

    if attendance.flaked && event.flake_penalty
        hours *= -1 
    end

    return hours
  end
end
