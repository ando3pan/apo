class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 	attr_accessor :login

	validates :username, presence: true, uniqueness: true, length: { minimum: 3 }, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }, :case_sensitive => false
  validates :firstname, presence: true, length: { minimum: 1 }
  validates :lastname, presence: true, length: { minimum: 1 }
  validates :phone, presence: true, uniqueness: true, length: { minimum: 10 }


  before_save do
  	self.a_username = self.username.downcase
  	self.nickname ||= self.firstname
    self.family = "None"
    self.membership_status = "Unknown"
    self.standing = "Unknown"
    self.displayname = "#{self.nickname} #{self.lastname}"
	end

	def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_h).first
    end
  end

end
