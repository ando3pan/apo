class GreensheetSection < ActiveRecord::Base
belongs_to :user

  def self.calculateHours(attendance, event)
    #return 0 if !attendance.attended
    hours = 0
    #hours = attendance.drove ? event.driver_hours : event.hours
    unless attendance.flaked || attendance.replacement_flaked
      
      event.driver_hours = event.hours if event.driver_hours.nil?
      hours = attendance.drove ? event.driver_hours : event.hours
      hours = attendance.drove ? (event.driver_hours-event.hours) + 0.5 * event.hours : 0.5*event.hours if attendance.late
    end

    if attendance.flaked && event.flake_penalty
        hours= event.hours * -1 
    end
    if attendance.replacement_flaked && event.flake_penalty
        hours = event.hours * -0.5 
    end

    return hours
  end
end
