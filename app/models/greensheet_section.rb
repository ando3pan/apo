class GreensheetSection < ActiveRecord::Base
belongs_to :user

  def self.calculateHours(attendance, event)
    return 0 if !attendance.attended
    hours = event.hours
    unless attendance.flaked || attendance.replacement_flaked
      if event.driver_hours == Null
          event.driver_hours = event.hours
      end
      hours = event.driver_hours if attendance.drove
    end

    if attendance.flaked && event.flake_penalty
        hours *= -1 
    end
    if attendance.replacement_flaked && event.flake_penalty
        hours *= -0.5 
    end

    return hours
  end
end
