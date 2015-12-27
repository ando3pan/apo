class UserController < ApplicationController
	before_action :ensure_user

	def show
		#events = current_user.attending_events.where('end_time >= ?', Time.now).order(:start_time)
		attendances = Attendance.where(user_id: @user.id)
		events = attendances.map{|x| Event.find(x.event_id)}
    @events = events.any? ? events.group_by{|x| x.start_time.strftime("%m/%d (%A)")} : nil
		# how can I make this prettier
		@hours = 0
		@flakehours = 0
		@fellowships = 0
		@user.attendances.where(past_quarter: false).each do |a|
			event = Event.find(a.event_id)
			if event.event_type == "Service"
				if a.attended?
					@hours += a.drove ? event.driver_hours : event.hours
				elsif event.flake_penalty? && a.flaked?
					@flakehours += event.hours
				end
			elsif event.event_type == "Fellowship" && a.attended?
				@fellowships += 1
			end
		end
	end

	def greensheet
    #@eventtypes = ["Service", "Fellowship", "Interchapter", "Fundraising", 
    #               "Family", "Rush" ] #for dropdown in view
    
    @hours = 0 
    @fellowships = 0
    @ics = 0
    @family = 0
    @rush = 0
    @fundraise = 0

    @texts = GreensheetText.where(user_id: @user.id) #comment sections
    unless @texts.any? #initialize comment sections
      GreensheetText.titles.zip(GreensheetText.descriptions).each do |t,d|
      @texts.push(GreensheetText.create(user_id: @user.id,
                                        title: t,
                                        description: d))
      end
    end

    if request.patch?
      if params[:greensheet_text] #updated a comment
        @text = GreensheetText.find(params[:greensheet_text][:id])
        if @text.update_attributes(greensheet_text_params)
          flash[:success] = "Greensheet successfully updated."
        else
          flash[:alert] = "There may have been problems saving."
        end
      
      else #updated an event
        @section = GreensheetSection.find(params[:greensheet_section][:id])
        if @section.update_attributes(greensheet_section_params)
          flash[:success] = "Greensheet successfully updated."
        else
          flash[:alert] = "There may have been problems saving."
        end
      end
      @sections = GreensheetSection.where(user_id: @user.id)
    end #end request.patch?

    if request.get?
      @sections = GreensheetSection.where(user_id: @user.id)
      @sections ||= []
      #already saved greensheet parts

      attendances = Attendance.where(user_id: @user.id)
      
      @user.attendances.where(past_quarter: false).each do |a|
        event = Event.find(a.event_id)
        
        dont_add = false 
        #@sections already has that event, or no attendance

        @sections.each do |s|
          dont_add = true if s.title == event.title #already exists
        end
        dont_add = true if !a.attended && !a.flaked #no show but no consequence
        dont_add = true if a.flaked && !event.flake_penalty #no consequence
          
        unless dont_add
          if ["Alpha", "Phi", "Omega", "Rho", "Pi"].include? event.event_type
            event.event_type = "Family" #list family for dropdown
          end

          hours = event.hours
          #hours = 1 if event.event_type != "Service"
          if a.flaked && event.flake_penalty
            if event.event_type == "Service"
              hours *= -1
            else
              hours = -1
            end
          end
          hours = event.driver_hours if a.drove

          case event.event_type
          when "Service"
            @hours += hours
          when "Fellowships"
            @fellowships += hours
          when "Interchapter"
            @ics += hours
          when "Family"
            @family += hours
          when "Rush"
            @rush += hours
          when "Fundraising"
            @fundraise += hours
          end

          @sections.push(GreensheetSection.create( user_id: @user.id, 
                                                   title: event.title,
                                                   start_time: event.start_time,
                                                   hours: hours,
                                  chair: User.find(event.chair_id).displayname,
                                                   event_type: event.event_type,
                                          original_event_type: event.event_type
          ))
        end
      end
    end #of the request.get? 

    @sections.each do |s|
      case s.event_type
      when "Service"
        @hours += s.hours
      when "Fellowship"
        @fellowships += s.hours
      when "Interchapter"
        @ics += s.hours
      when "Family"
        @family += s.hours
      when "Rush"
        @rush += s.hours
      when "Fundraising"
        @fundraise += s.hours
      end
    end
    if request.patch?
      render 'greensheet'
    end

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

  def greensheet_section_params
    params.require(:greensheet_section).permit(:title, :start_time, :hours, 
                                 :chair_id, :event_type, :original_event_type)
  end

  def greensheet_text_params
    params.require(:greensheet_text).permit(:title, :description, :text)
  end
end
