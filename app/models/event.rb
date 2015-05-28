class Event < ActiveRecord::Base
	belongs_to :user # The organiser
	has_many :attendances, dependent: :destroy
	has_many :participants, through: :attendances, source: :user 

	validates :title, presence: true
	validates :start_time, presence: true
	validates :end_time, presence: true
	validates :attendance_cap, presence: true
end
