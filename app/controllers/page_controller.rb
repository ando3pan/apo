class PageController < ApplicationController
  def home
  end

  def calendar
  	@events = Event.all
  end

  def admin
  	if !user_signed_in? || !current_user.admin
  		redirect_to root_path
  	end
  end
  
end
