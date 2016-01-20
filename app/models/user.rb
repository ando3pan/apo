class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 	attr_accessor :login

  has_many :attendances, dependent: :destroy
  has_many :attending_events, through: :attendances, source: :event #for the participants
  has_many :events #for the event organiser

  has_many :greensheet_sections
  accepts_nested_attributes_for :greensheet_sections, allow_destroy: true
  has_many :greensheet_texts
  accepts_nested_attributes_for :greensheet_texts, allow_destroy: true

	validates :username, presence: true, uniqueness: true, length: { minimum: 3 }, format: { with: /\A[a-zA-Z0-9]+\z/,
    message: "only allows letters and numbers" }, :case_sensitive => false
  validates :firstname, presence: true, length: { minimum: 1 }
  validates :lastname, presence: true, length: { minimum: 1 }
  validates :phone, presence: true, length: { minimum: 10 }


  before_save do
  	self.a_username = self.username.downcase.strip
    self.firstname = self.firstname.strip
    self.lastname = self.lastname.strip
  	self.nickname = (self.nickname == "" ? self.firstname : self.nickname).strip
    self.displayname = (self.displayname == "" ? "#{self.firstname} #{self.lastname}" : self.displayname)
	end

	def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_h).first
    end
  end

  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super and self.approved?
  end

end
