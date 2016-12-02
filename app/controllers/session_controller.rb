class SessionController < Devise::SessionsController
  before_filter :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :username])#.for(:sign_in).push(:login, :username)
                              
  end
end
