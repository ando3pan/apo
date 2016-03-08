class UserController < ApplicationController
	before_action :ensure_user
  before_action :set_quarter_cutoff, only: [:show, :greensheet]

	def show
		attendances = Attendance.where(user_id: @user.id)

		@attendances = attendances.where("created_at >  ?", @quarter_cutoff )
		@attended_events = @attendances.map{|x| Event.find(x.event_id)}
    @events = @attended_events.any? ? @attended_events.group_by{|x| x.start_time.strftime("%m/%d (%A)")} : nil
    @events = @events.sort_by { |date, evt| date } if @events #events isnt null
		# how can I make this prettier
		@hours = 0
		@flakehours = 0
		@fellowships = 0
		@user.attendances.each do |a|
			event = Event.find(a.event_id)
			if event.end_time > @quarter_cutoff
				if event.event_type == "Service"
					if a.attended?
						@hours += a.drove ? event.driver_hours : event.hours
					elsif event.flake_penalty? && a.flaked?
						@flakehours += event.hours
					end
				elsif event.event_type == "Fellowship"
					@fellowships += GreensheetSection.calculateHours(a, event)
				end
			end
		end
	end

	def greensheet
    @reqs = Hash.new(0) #contain all the diff requirement counters

    @texts = GreensheetText.where(user_id: @user.id).order(:created_at) #comment sections
    
    unless @texts.any? #initialize comment sections
      #modify titles/descriptions in app/models/greensheet_text.rb file
      GreensheetText.titles.zip(GreensheetText.descriptions).each do |t,d|
        gtext = GreensheetText.create(user_id: @user.id, title: t,
                                      description: d)
        @texts.push(gtext) unless @texts.include?(gtext)#avoid duplicate problem
      end
    end

    if request.patch? #update any potential changes
      if @user.update(greensheet_sections_attributes: params[:user][:greensheet_sections_attributes])
         if @user.update(greensheet_texts_attributes: params[:user][:greensheet_texts_attributes])
           flash[:success] = "Greensheet successfully updated."
         end
      else
        flash[:alert] = "There may have been problems saving."
      end
      
      @sections = GreensheetSection.where(user_id: @user.id)
    end #end request.patch?

    if request.get?
      @sections = GreensheetSection.where(user_id: @user.id)
      @sections ||= [] #no saved sections yet

      @user.attendances.where("created_at > ?", @quarter_cutoff).each do |a|
        event = Event.find(a.event_id)
        
        dont_add = false 
        #@sections already has that event, or no attendance


        #already exists, may be event changes
        gsheet = GreensheetSection.find_by(event_id: a.event_id, 
                                           user_id: @user.id) 

        dont_add = true if gsheet #already exists
        dont_add = true if !a.attended && !a.flaked #no show but no consequence
        dont_add = true if a.flaked && !event.flake_penalty #no consequence
          
        unless dont_add
          chair = User.find_by(id: event.chair_id)
          chair = chair ? chair.displayname : "No Chair"

          #accounts for flaking and all
          hours = GreensheetSection.calculateHours(a, event)

          if ["Alpha", "Phi", "Omega", "Rho", "Pi"].include? event.event_type
            event.event_type = "Family" #list family for dropdown
          end

          @sections.push(GreensheetSection.create( user_id: @user.id, 
                                                   title: event.title,
                                                   start_time: event.start_time,
                                                   hours: hours,
                                                   chair: chair,
                                                   event_type: event.event_type,
                                          original_event_type: event.event_type,
                                          event_id: event.id
          ))
        end
      end
    end #of the request.get? 

    @sections = @sections.uniq #rid of more duplicate problems

    @sections.each do |s|
      case s.event_type
      when "Service"
        @reqs[:hours] += s.hours
      when "Fellowship"
        @reqs[:fellowships] += s.hours
      when "Interchapter"
        @reqs[:ics] += s.hours
      when "Family"
        @reqs[:family] += s.hours
      when "Rush"
        @reqs[:rush] += s.hours
      when "Fundraising"
        @reqs[:fundraise] += s.hours
      when "Other"
        @reqs[:interviewparties] += 1 if s.title.include? "Interview"
        @reqs[:infonights] += 1 if s.title.include? "Info"
        @reqs[:flyering] += 1 if s.title.include? "Flyering"
        @reqs[:chalkboarding] += 1 if s.title.include? "Chalkboard"
      end
    end

=begin    latest_section = @sections.order('updated_at DESC').first
    if latest_section #nil check
      @last_updated = latest_section.updated_at
      @last_updated ||= Time.now
    end
=end
    @sections = @sections.order(:event_type, :start_time )
	end

	def update
		@edit = true
		updater = current_user.id
		if request.patch?
			user_params[:firstname].strip!
			user_params[:lastname].strip!
			if @user.update_attributes(user_params)
				@user.update_attribute(:displayname, user_params[:firstname] + ' ' + user_params[:lastname])
				if updater == @user.id
					sign_in(@user, :bypass => true)
				end
				if !request.xhr?
					flash[:success] = "Profile successfully updated."
					render 'update'
				end
			elsif !request.xhr?
				flash[:alert] = "There may have been errors saving."
				render 'update'
			end
		end
	end

	def all
		unless current_user.admin?
			flash[:alert] = "You do not have permission to access that page."
			redirect_to root_path
		end
		@users = User.order('created_at DESC').where(approved: true)
	end

	private

	def user_params
    params.require(:user).permit(:name, :email, :password, :firstname, :lastname, :nickname, :displayname,
      :phone, :family, :line, :pledge_class, :membership_status, :major, :graduation_year, :shirt_size, :car,
      :password, :password_confirmation)
	end

	def ensure_user
		@user = User.find_by_a_username(params[:id])
		@user ||= User.find(params[:id])
    unless user_signed_in? && (current_user.id == @user.id || current_user.admin)
      redirect_to root_path, notice: "You do not have permission to see that page."
    end
  end

  def set_quarter_cutoff
    s = Setting.first
    @quarter_cutoff = Time.parse(s.fall_quarter.to_s)

    winter = Time.parse(s.winter_quarter.to_s)
    spring = Time.parse(s.spring_quarter.to_s)

    if Time.now > spring
      @quarter_cutoff = spring
    elsif Time.now > winter
      @quarter_cutoff = winter
    end
  end

end
