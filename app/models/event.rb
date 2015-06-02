class Event < ActiveRecord::Base
	belongs_to :user # The organiser
	has_many :attendances, dependent: :destroy
	has_many :participants, through: :attendances, source: :user 

	validates :title, presence: true
	validates :start_time, presence: true
	validates :end_time, presence: true
	validates :attendance_cap, presence: true

  before_save do
  	self.start_time = self.start_time.in_time_zone("Pacific Time (US & Canada)")
    self.end_time = self.end_time.in_time_zone("Pacific Time (US & Canada)")
	end
end
