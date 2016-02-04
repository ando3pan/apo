class ForumController < ApplicationController
  before_filter :ensure_signed_in

  def show
    @forums = Forum.all.order(updated_at: :desc)
  end

  #create a new forum
  def new
    if request.get?
      @forum = Forum.new
    elsif request.post?
      @forum = Forum.create
      if @forum.update_attributes(forum_params)
        flash[:success] = "Forum successfully created"
      elsif
        flash[:alert] = "Error creating forum"
      end
      redirect_to forum_path
    end
  end

  #after clicking on a specific forum
  def topic
    @forum = Forum.find( params[:id])
    @topics = Topic.where(forum_id: params[:id]).order(updated_at: :desc)
    render "forum/topic/show"
  end

  #create a new topic
  def new_topic
    @forum = Forum.find( params[:id])
    if request.get?
      @topic = Topic.new
      render "forum/topic/new"
    elsif request.post?
      @topic = Topic.create
      if @topic.update_attributes(topic_params)
        flash[:success] = "Topic successfully created"
      elsif
        flash[:alert] = "Error creating topic"
      end
      redirect_to topic_path
    end
  end

  def post
    render "forum/post/show"
  end

  private
  def forum_params
    params.require(:forum).permit(:title, :description, :creator_id )
  end

  def topic_params
    params.require(:topic).permit(:title, :creator_id, :forum_id )
  end

  def ensure_signed_in
    unless user_signed_in?
      redirect_to root_path, notice: "Please sign in."
    end
  end
end
