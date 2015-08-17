class UserController < ApplicationController
	before_action :ensure_user

	def show
		@events = @user.attending_events
		# how can I make this prettier
		@hours = 0
		@fellowships = 0
		@user.attendances.where(past_quarter: false).each do |a|
			event = Event.find(a.event_id)
			if event.event_type == "Service"
				if a.attended?
					@hours += a.drove ? event.driver_hours : event.hours
				elsif event.flake_penalty? && a.flaked?
					@hours -= event.ehours
				end
			elsif event.event_type == "Fellowship" && a.attended?
				@fellowships += 1
			end
		end
	end

	def update
		@edit = true
		updater = current_user.id
		if request.patch?
			if @user.update_attributes(user_params)
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

end