#each post within a discussion, such as commentary about a specific bylaw
#amendment
class Post < ActiveRecord::Base
  belongs_to :topic
end
