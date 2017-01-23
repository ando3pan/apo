class RegistrationController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    #devise_parameter_sanitizer.for(:sign_up).push(:username, :firstname, :lastname, :nickname, :phone, :email)
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :firstname, :lastname, :nickname, :phone, :email])
  end
end
