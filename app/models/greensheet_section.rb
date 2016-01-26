class GreensheetSection < ActiveRecord::Base
belongs_to :user

  def self.calculateHours(attendance, event)
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
