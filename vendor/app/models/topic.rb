#contains more specific discussion (than Forum), such as a specific bylaw
#amendment
class Topic < ActiveRecord::Base
  belongs_to :forum
  has_many :posts, dependent: :destroy
end
