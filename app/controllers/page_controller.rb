class PageController < ApplicationController
  before_action :ensure_admin, only: [:admin, :approve, :settings]
  skip_before_action :verify_authenticity_token

  def home
    # WOW! UNSAFE! THESE KEYS ARE PRIVATE! LUCKY WE USE A PRIVATE REPO!
    if user_signed_in?
      client = Tumblr::Client.new({
        :consumer_key => 'RisNrdCaXVBh2WcQcfgqFC7HiJUgzu8hwVyT0sB5M7e7tDScRM',
        :consumer_secret => 'xAvy3FvPj9dJXkFwv1l2Q2GH6Ibcdf8wvAGVH9NrkBPmUVcRkP',
        :oauth_token => 'F2RWp0e32YjlYJH21cmW5Ncb5TggWKcb0PzB2wdgfyiTo4LaXu',
        :oauth_token_secret => 'CjzN4wbFENzZpojSEsKj5AZH9yYXwWvlEJsFdQTP5bsERn5kZo'
      })
      @posts = client.posts('aporhopi.tumblr.com', :tag => 'announcement', :limit => 10)["posts"]
    end
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

  def settings
  end

  private
  def ensure_admin
    unless user_signed_in? && current_user.admin
      redirect_to root_path, notice: "Only admins may access that page."
    end
  end
  
end
