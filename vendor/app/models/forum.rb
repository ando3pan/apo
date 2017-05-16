#contains broad categories such as "Amendments"
class Forum < ActiveRecord::Base
  has_many :topics, dependent: :destroy
  has_many :posts, through: :topics 

  validates :title, presence: true
  validates :description, presence: true
end
