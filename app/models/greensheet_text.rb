class GreensheetText < ActiveRecord::Base
  def self.titles
    ["Changed event type", "Which service was your favorite?",
    "Which fellowship was your favorite?", "Committee",
    "Other Fundraising Credits", "Final Thoughts"]
  end

  def self.descriptions
    ["If you changed an event's type to \"Other\", please list what you want it
     to count towards",
     "Have any comments about this quarter's services?",
     "Have any comments about this quarter's fellowships?",
     "What committee were you in?",
     "(i.e. receipts, recycling)",
     "Anything else you'd like to share?"]
   end
end
