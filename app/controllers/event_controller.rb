class EventController < ApplicationController
	before_action      :ensure_signed_in
	before_action      :ensure_admin, only: [:new, :destroy, :meeting]
	skip_before_action :verify_authenticity_token

	def show
		@event   = Event.find(params[:id])
		attendances = @event.attendances
		# If you're not a driver:
		# no driver: block if 4 signups
		# 1 driver: block if 9 signups
		# 2 drivers: block if 14 signups
		# if you're a driver:
		# if no driver: require drive if 4 signups
		# 1 driver: require drive if 9 signups
		# 2 drivers: require drive if 14 signups
		@needs_driver = @event.off_campus &&
			attendances.count - (attendances.where(can_drive: true).count * 5) == 4
		@holiday = matches_holiday(@event.start_time)
		unless @event.public || current_user.admin
			redirect_to root_path, notice: "The event is not yet public."
		end
	end

	def meeting
		@event = Event.find(params[:id])
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
		if Time.now < @event.start_time - 1.week  ||
			@event.attendances.find_by_user_id(current_user.id).created_at > Time.now - 20.minutes
			a = @event.attendances.find_by_user_id(params[:attendance][:user_id])
			if a.chair && @event.chair_id == params[:attendance][:user_id].to_i
				@event.update_attribute(:chair_id, nil)
			end
			a.destroy
			redirect_to event_path(@event.id)
		else
			flash[:error] = "It's too late to cancel your signup."
			redirect_to event_path(@event.id)
		end
	end

	def new
		if request.get?
			if params[:edit] # I'm lazy so we reuse this endpoint
				@event  = Event.find(params[:edit])
				@copy   = @event
				@action = "Save Changes"
			else
				@event = current_user.events.create
				@event.flake_penalty = false # oops this should default to false
				@action = "Create"
				if params[:dup]
					@copy  = Event.find(params[:dup])
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
						distance: @copy.distance,
						off_campus: @copy.off_campus
						)
				end
			end
		elsif request.post?
			if params[:event][:action] == "Create"
				@event = current_user.events.create(event_params)
			else
				@event = Event.find(params[:event][:id])
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
				@action = params[:event][:action]
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
		@event = Event.find(params[:id])
		unless current_user.admin || @event.chair_id == current_user.id
			redirect_to event_path(@event)
		end
		@attendances = @event.attendances.order(:created_at).sort_by { |a| a.flaked ? 1 : 0 }
	end

	def chairsheet
		@event = Event.find(params[:id])
		# rebuild the relations
		@event.attendances.clear
		params[:u].each do |key, a|
			# If a name is given
		  if a["firstname"].length > 0 && a["lastname"].length > 0 && a["attendance"] != "waitlist"
		  	name = "#{a['firstname']} #{a['lastname']}"
		  	user = User.where("lower(displayname) = ?", name.downcase).first
		  	if user
		  		# add the user
		  		@event.participants << user
		  		attendee = @event.attendances.find_by_user_id(user.id)

			  	#  Update the relation
			  	attendee.update_attribute(:attended, a["attendance"] == "attended" || a["attendance"] == "replaced")
		  		attendee.update_attribute(:flaked,   a["attendance"] == "flaked")
		  		attendee.update_attribute(:chair,    a.has_key?("chair"))
		  		attendee.update_attribute(:drove,    a.has_key?("drove"))
		  	end
		  end
		end

		flash[:success] = "Chairsheet updated."
		redirect_to event_path(@event)
	end

	def events_feed
		events = []
		start_time = Time.parse(params[:start])
		end_time = Time.parse(params[:end]).end_of_day
		allevents = Event.where(public: true)
		if params[:filter].downcase != "none"
			allevents = allevents.where(event_type: params[:filter].capitalize)
		end
		allevents.where(:start_time => start_time.beginning_of_day..end_time).each do |e|
			# ya'll not ready for this sick syntax
			events.push({
				title: "#{e.title}",
				start: e.start_time,
				end: e.end_time,
				color: get_event_color(e),
				url: "/event/#{e.id}",
				description: get_event_description(e),
				event_type: e.event_type
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
      redirect_to root_path, notice: "You don't have permission to access that page."
    end
  end

	def event_params
    params.require(:event).permit(:title, :start_time, :end_time, :location, :address, :event_type,
    	:hours, :driver_hours, :distance, :flake_penalty, :info, :contact, :attendance_cap, :public, :off_campus, :user_id)
	end

	def get_event_color(e)
		type = e.event_type
		opacity = 1
		if type == "Service"
			"rgba(57, 73, 171, #{opacity})"
		elsif type == "Fellowship"
			"rgba(124, 101, 171, #{opacity})"
		elsif type == "Fundraising"
			"rgba(96, 163, 99, #{opacity})"
		elsif type == "Rush"
			"rgba(199, 140, 66, #{opacity})"
		elsif type == "Interchapter"
			"rgba(216, 27, 96, #{opacity})"
		elsif type == "Alpha"
			"rgba(237, 204, 57, #{opacity})"
		elsif type == "Phi"
			"rgba(123, 31, 162, #{opacity})"
		elsif type == "Omega"
			"rgba(13, 71, 161, #{opacity})"
		elsif type == "Rho"
			"rgba(198, 40, 40, #{opacity})"
		elsif type == "Pi"
			"rgba(56, 142, 60, #{opacity})"
		else
			"rgba(85, 85, 85, #{opacity})"
		end
	end

	def get_event_description(e)
		str = ""
		if e.attendance_cap > 0
			if e.participants.size >= e.attendance_cap
				str += "<div style='color: #FFB4B3'>#{e.participants.size}/#{e.attendance_cap} participants</div>"
			else
				str += "<div>#{e.participants.size}/#{e.attendance_cap} participants</div>"
			end
		else
			str += "<div>#{e.participants.size} signed up</div>"
		end
		str
	end

	def matches_holiday(start_time)
		holidays = get_holidays["holidays"]
		holidays.each do |h|
			if h["DTEND;VALUE=DATE"]
				# check if within range
				starts = Time.parse(h["DTSTART;VALUE=DATE"]).beginning_of_day
				ends   = Time.parse(h["DTEND;VALUE=DATE"]).end_of_day
				if (start_time > starts && start_time < ends)
					return h["SUMMARY"]
				end
			elsif h["DTSTART;VALUE=DATE"]
				# check if date matching
				if Time.parse(h["DTSTART;VALUE=DATE"]).to_date === start_time.to_date
					return h["SUMMARY"]
				end
			end
		end
		return ""
	end

	def get_holidays
		holidays = %q({"holidays":
			[
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-371048566@marudot.com",
				  "DTSTART;VALUE=DATE": "20151111",
				  "SUMMARY": "Veterans Day Holiday"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-973734813@marudot.com",
				  "DTSTART;VALUE=DATE": "20151126",
				  "DTEND;VALUE=DATE": "20151128",
				  "SUMMARY": "Thanksgiving Holiday"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-757784175@marudot.com",
				  "DTSTART;VALUE=DATE": "20151205",
				  "DTEND;VALUE=DATE": "20151213",
				  "SUMMARY": "Final Exams"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-583254548@marudot.com",
				  "DTSTART;VALUE=DATE": "20151212",
				  "DTEND;VALUE=DATE": "20160103",
				  "SUMMARY": "Winter Break"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-1864151930@marudot.com",
				  "DTSTART;VALUE=DATE": "20160118",
				  "SUMMARY": "Martin Luther King Jr. Holiday"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-1416006441@marudot.com",
				  "DTSTART;VALUE=DATE": "20160215",
				  "SUMMARY": "Presidents' Day Holiday"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-1547653022@marudot.com",
				  "DTSTART;VALUE=DATE": "20160312",
				  "DTEND;VALUE=DATE": "20160319",
				  "SUMMARY": "Final Exams"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-2134040145@marudot.com",
				  "DTSTART;VALUE=DATE": "20160320",
				  "DTEND;VALUE=DATE": "20160327",
				  "SUMMARY": "Spring Break"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-1435734028@marudot.com",
				  "DTSTART;VALUE=DATE": "20160325",
				  "SUMMARY": "César Chávez Holiday"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-753281281@marudot.com",
				  "DTSTART;VALUE=DATE": "20160530",
				  "SUMMARY": "Memorial Day Observance"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-219421968@marudot.com",
				  "DTSTART;VALUE=DATE": "20160604",
				  "DTEND;VALUE=DATE": "20160611",
				  "SUMMARY": "Final Exams"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-381673714@marudot.com",
				  "DTSTART;VALUE=DATE": "20160611",
				  "DTEND;VALUE=DATE": "20160613",
				  "SUMMARY": "Commencement"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-16878912@marudot.com",
				  "DTSTART;VALUE=DATE": "20160704",
				  "SUMMARY": "Independence Day"
				},
				{
				  "DTSTAMP": "20140626T000702Z",
				  "UID": "20140626T000702Z-1153658679@marudot.com",
				  "DTSTART;VALUE=DATE": "20160905",
				  "SUMMARY": "Labor Day"
				}
			]
		})
		JSON.parse(holidays)
	end

end
