class PageController < ApplicationController
  def home
  end

  def events
    @events = Event.where(public: true).where(:start_time => Time.now..Time.now+1.weeks)
    @services = Event.where(event_type: "Service").where(public: true).where(:start_time => Time.now..Time.now+2.weeks)
  end

  def calendar
    unless user_signed_in?
      redirect_to root_path
    end
  end

  def admin
  	if !user_signed_in? || !current_user.admin
  		redirect_to root_path
  	end
  end
  
end
