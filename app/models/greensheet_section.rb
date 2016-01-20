class GreensheetSection < ActiveRecord::Base
belongs_to :user

  def self.calculateHours(attendance, event)
    hours = event.hours                                                     
    unless attendance.flaked
      hours = event.driver_hours if attendance.drove
    end

    if event.event_type != "Service"
      hours = 1 #non service events get 1 credit
    end

    if attendance.flaked && event.flake_penalty
      if event.event_type == "Service"                                      
        hours *= -1                                                         
      else                                                                  
        hours = -1                                                          
      end                                                                   
    end                                                                     

    return hours
  end
end
