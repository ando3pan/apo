class EventController < ApplicationController
	before_action :ensure_signed_in
	before_action :ensure_admin, only: [:new, :destroy]
	skip_before_action :verify_authenticity_token

	def show
		@event = Event.find(params[:id])
		unless @event.public || current_user.admin
			redirect_to root_path, notice: "The event is not yet public."
		end
	end

	def signup
		@event = Event.find(params[:attendance][:event_id])
		@event.participants << current_user
		attendance = @event.attendances.find_by_user_id(params[:attendance][:user_id])
		if params[:attendance][:chair]
			attendance.update_attribute(:chair, true)
			@event.update_attribute(:chair_id, params[:attendance][:user_id])
		end
		if params[:attendance][:will_drive]
			attendance.update_attribute(:can_drive, true)
		end
		redirect_to event_path(@event.id)
	end

	def cancel
		@event = Event.find(params[:attendance][:event_id])
		a = @event.attendances.find_by_user_id(params[:attendance][:user_id])
		if a.chair && @event.chair_id == params[:attendance][:user_id]
			@event.update_attribute(:chair_id, nil)
		end
		a.destroy
		redirect_to event_path(@event.id)
	end

	def new
		if request.get?
			if params[:edit] # I'm lazy so we reuse this endpoint
				@event = Event.find(params[:edit])
				@copy = @event
				@action = "Save Changes"
			else
				@event = current_user.events.create
				@event.flake_penalty = false # oops this should default to false
				@action = "Create"
				if params[:dup]
					@copy = Event.find(params[:dup])
					@event = current_user.events.create(
						title: @copy.title,
						location: @copy.location,
						address: @copy.address,
						event_type: @copy.event_type,
						info: @copy.info,
						contact: @copy.contact,
						attendance_cap: @copy.attendance_cap,
						flake_penalty: @copy.flake_penalty,
						public: @copy.public,
						hours: @copy.hours,
						driver_hours: @copy.driver_hours,
						distance: @copy.distance
						)
				end
			end
		elsif request.post?
			@event = Event.find(params[:event][:id])
			if params[:event][:action] == "Create"
				@event = current_user.events.create(event_params)
			else
				@event.update_attributes(event_params)
			end
			if @event.driver_hours == 0
				@event.driver_hours = @event.hours
			end
			if @event.save
				redirect_to event_path(@event)
				if params[:event][:action] == "Create"
					flash[:success] = "Event successfully created."
				else
					flash[:success] = "Event successfully updated."
				end
			else
				flash[:alert] = "Errors: #{@event.errors.full_messages.join(", ")}"
				render 'new'
			end
		else
			redirect_to root_path
		end
	end

	def destroy
		if current_user.admin?
			Event.find(params[:id]).destroy
			flash[:success] = "Event was successfully deleted."
		end
		redirect_to events_path
	end

	def chair
		unless current_user.admin || @event.chair_id == current_user.id
			redirect_to event_path(@event)
		end
		@event = Event.find(params[:id])
		@attendances = @event.attendances
	end

	def chairsheet
		@event = Event.find(params[:id])
		@attendances = @event.attendances
		params[:u].each do |key, a|
			# If a name is given
		  if a["firstname"].length > 0 && a["lastname"].length > 0
		  	user = User.where(firstname: a["firstname"]).where(lastname: a["lastname"]).first
		  	puts "#{a['firstname']} #{user}"
		  	unless user == nil
		  		# Updating user's relation
		  		attendee = @attendances.find_by_user_id(user.id)
		  		unless attendee
			  		# build relation for the replacement
			  		@event.participants << user
			  		attendee = @attendances.last
			  	end

			  	#  Update the relation
			  	attendee.update_attribute(:attended, a["attendance"] == "attended")
		  		attendee.update_attribute(:flaked,   a["attendance"] == "flaked")
		  		attendee.update_attribute(:chair,    a.has_key?("chair"))
		  		attendee.update_attribute(:drove,    a.has_key?("drove"))
		  	else
		  		# Error: user not found

		  	end
		  end
		end
		render 'chair'
	end

	def events_feed
		events = []
		start_time = Time.parse(params[:start])
		end_time = Time.parse(params[:end]).end_of_day
		Event.where(public: true).where(:start_time => start_time.beginning_of_day..end_time).each do |e|
			# ya'll not ready for this sick syntax
			events.push({
									title: e.title,
									start: e.start_time,
									end: e.end_time,
									color: get_event_color(e.event_type),
									textColor: e.participants.size >= e.attendance_cap && e.attendance_cap > 0 ? "#FF7575" : "white",
									url: "/event/#{e.id}",
									description: e.participants.include?(current_user) ? "You're going." : ""
								 })
		end
		render json: events
	end

	private
	def ensure_signed_in
    unless user_signed_in?
      redirect_to root_path, notice: "Please sign in."
    end
  end

  def ensure_admin
    unless user_signed_in? && current_user.admin
      redirect_to root_path, notice: "Only admins may access that page."
    end
  end

	def event_params
    params.require(:event).permit(:title, :start_time, :end_time, :location, :address, :event_type,
    	:hours, :driver_hours, :distance, :flake_penalty, :info, :contact, :attendance_cap, :public, :user_id)
	end

	def get_event_color(type)
		if type == "Service"
			"#3949AB"
		elsif type == "Fellowship"
			"#5E35B1"
		elsif type == "Fundraising"
			"#388E3C"
		else
			"#555555"
		end
	end

end
