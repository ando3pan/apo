class GreensheetSection < ActiveRecord::Base
belongs_to :user

  def self.calculateHours(attendance, event)
    return 0 if !attendance.attended
    hours = event.hours
    unless attendance.flaked || attendance.replacement_flaked
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
