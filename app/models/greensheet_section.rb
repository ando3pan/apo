class GreensheetSection < ActiveRecord::Base
belongs_to :user

  def self.calculateHours(attendance, event)
    hours = event.hours                                                     
    if attendance.flaked && event.flake_penalty
      if event.event_type == "Service"                                      
        hours *= -1                                                         
      else                                                                  
        hours = -1                                                          
      end                                                                   
    end                                                                     

    hours = event.driver_hours if attendance.drove
    return hours
  end
end
