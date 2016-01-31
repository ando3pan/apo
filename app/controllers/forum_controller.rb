class ForumController < ApplicationController
  def show
    @forums = Forum.all.order(:updated_at)
  end

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

  private
  def forum_params
    params.require(:forum).permit(:title, :description, :creator_id )
  end
end
