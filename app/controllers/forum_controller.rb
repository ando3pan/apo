class ForumController < ApplicationController
  before_filter :ensure_signed_in

  def show
    @forums = Forum.all.order(updated_at: :desc)
  end

  def destroy_forum
    f = Forum.find(params[:id])
    if f.delete
      flash[:success] = "Deleted successfully"
    elsif
      flash[:alert] = "Delete failed"
    end
    redirect_to forum_path
  end

  def edit_forum
    @forum = Forum.find(params[:id])
    if request.patch?
      if @forum.update_attributes(forum_params)
        flash[:success] = "Edited successfully"
      elsif
        flash[:alert] = "Error saving edit"
      end
      redirect_to forum_path
    end
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
      redirect_to topic_path(@forum)
    end
  end

  def destroy_topic
    t = Topic.find(params[:id])
    @forum = Forum.find( t.forum_id )
    if t.delete
      flash[:success] = "Deleted successfully"
    elsif
      flash[:alert] = "Delete failed"
    end
    redirect_to topic_path(@forum) 
  end

  def edit_topic
    @topic = Topic.find(params[:id])
    @forum = Forum.find( @topic.forum_id )
    if request.patch?
      if @topic.update_attributes(topic_params)
        flash[:success] = "Edited successfully"
      elsif
        flash[:alert] = "Error saving edit"
      end
      redirect_to topic_path(@forum) 
    else
      render "forum/topic/edit_topic"
    end
  end

  def post
    @topic = Topic.find( params[:id] )

    if request.post?
      @post = Post.create
      if @post.update_attributes(post_params)
        flash[:success] = "Post created"
        @topic.update_attribute(:updated_at, @post.updated_at )
        @forum = Forum.find( @topic.forum_id )
        @forum.update_attribute(:updated_at, @post.updated_at )
      else
        flash[:alert] = "Error creating post"
      end
    end

    @new_post = Post.new
    @posts = Post.where(topic_id: params[:id]).order(:created_at)
    render "forum/post/show"
  end

  def edit_post
    @post = Post.find( params[:id] )
    @topic = Topic.find(@post.topic_id)
    if request.patch?
      if @post.update_attributes(post_params)
        flash[:success] = "Edited successfully"
      elsif
        flash[:alert] = "Error saving edit"
      end
      redirect_to post_path(@topic)
    else
      render "forum/post/edit_post"
    end
  end

  def destroy_post
    p = Post.find(params[:id])
    @topic = Topic.find( p.topic_id )
    if p.delete
      flash[:success] = "Deleted successfully"
    elsif
      flash[:alert] = "Delete failed"
    end
    redirect_to post_path(@topic) 
  end

  private
  def forum_params
    params.require(:forum).permit(:title, :description, :creator_id )
  end

  def topic_params
    params.require(:topic).permit(:title, :creator_id, :forum_id )
  end

  def post_params 
    params.require(:post).permit(:comment, :creator_id, :topic_id)
  end

  def ensure_signed_in
    unless user_signed_in?
      redirect_to root_path, notice: "Please sign in."
    end
  end
end
