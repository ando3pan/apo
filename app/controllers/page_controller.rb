class PageController < ApplicationController
  before_action :ensure_admin, only: [:admin, :approve]
  skip_before_action :verify_authenticity_token

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
  end

  def approve
    if request.get?
      @users = User.where(approved: false)
    elsif request.post?
      # the hash uses user id as a key
      params[:u].each do |key, args|
        user = User.find(key.to_i)
        if (args["approved"])
          # approve
          user.update_attribute(:approved, true)
        elsif (args["rejected"])
          # delete account
          user.destroy
        end
      end
      redirect_to approve_path
    end
  end

  private
  def ensure_admin
    unless user_signed_in? && current_user.admin
      redirect_to root_path, notice: "Only admins may access that page."
    end
  end
  
end
