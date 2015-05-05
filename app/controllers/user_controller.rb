class UserController < ApplicationController

	def show
		@user = User.find_by_a_username(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user == current_user
			@edit = true
			if request.patch?
				if @user.update_attributes(user_params)
					sign_in(@user, :bypass => true)
					@success = true
					render 'update'
				else
					puts @user.errors.full_messages
					render 'update'
				end
			end
		end
	end

	private

	def user_params
    params.require(:user).permit(:name, :email, :password, :firstname, :lastname, :nickname, :displayname,
      :phone, :family, :line, :pledge_class, :membership_status, :major, :graduation_year, :shirt_size, :car, 
      :password, :password_confirmation)
	end

end