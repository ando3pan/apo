class AddTopicIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :topic_id, :integer, default: 0
  end
end
