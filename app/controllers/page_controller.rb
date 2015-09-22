class PageController < ApplicationController
  before_filter :ensure_signed_in, except: [:home]
  before_action :ensure_admin, only: [:admin, :approve, :settings]
  skip_before_action :verify_authenticity_token

  def home
    # WOW! UNSAFE! THESE KEYS ARE PRIVATE! LUCKY WE USE A PRIVATE REPO!
    if user_signed_in?
      @posts = tumblr.posts('aporhopi.tumblr.com', :tag => 'announcement', :limit => 10)["posts"] rescue []
      events = current_user.attending_events.where('end_time >= ?', Time.now).order(:start_time)
      @events = events.any? ? events.group_by{|x| x.start_time.strftime("%m/%d (%A)")} : nil
    end
  end

  def events
    events = Event.where.not(event_type: "Service").where(public: true)
      .where(:start_time => Time.now..Time.now+1.weeks).order(:start_time)
    @events = events.any? ? events.group_by{|x| x.start_time.strftime("%m/%d (%A)")} : nil
    services = Event.where(event_type: "Service").where(public: true)
      .where(:start_time => Time.now..Time.now+1.weeks).order(:start_time)
    @services = services.any? ? services.group_by{|x| x.start_time.strftime("%m/%d (%A)")} : nil
    @spotlight = tumblr.posts('aporhopi.tumblr.com', :tag => 'spotlight', :limit => 1)["posts"] rescue nil
  end

  def calendar
    @month = params[:load] ? params[:load] : Time.now.to_date
    @filter = params[:filter] ? params[:filter] : "none"
    # hehe ghetto
    if request.fullpath.include?("filter=")
      if request.fullpath.include?("load=")
        @filterpath = request.path + "?load=" + params[:load] + "&filter="
      else
        @filterpath = request.path + "?filter="
      end
    else
      @filterpath = request.fullpath.include?("?") ? request.fullpath + "&filter=" : request.fullpath + "?filter="
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
          # delete accoun
          user.destroy
        end
      end
      redirect_to approve_path
    end
  end

  def settings
  end

  private
  def tumblr
    Tumblr::Client.new({
      :consumer_key => 'RisNrdCaXVBh2WcQcfgqFC7HiJUgzu8hwVyT0sB5M7e7tDScRM',
      :consumer_secret => 'xAvy3FvPj9dJXkFwv1l2Q2GH6Ibcdf8wvAGVH9NrkBPmUVcRkP',
      :oauth_token => 'F2RWp0e32YjlYJH21cmW5Ncb5TggWKcb0PzB2wdgfyiTo4LaXu',
      :oauth_token_secret => 'CjzN4wbFENzZpojSEsKj5AZH9yYXwWvlEJsFdQTP5bsERn5kZo'
    })
  end

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

end
