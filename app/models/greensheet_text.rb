class GreensheetText < ActiveRecord::Base
  def self.titles
    ["Changed event type", "Other events", "Which service was your favorite?",
    "Which fellowship was your favorite?", "Committee",
    "Other Fundraising Credits", "GBM Full Attendance", 
    "GBM Half Attendance", "Final Thoughts"]
  end

  def self.descriptions
    ["If you changed an event's type to \"Other\", please list what you want it
     to count towards",
     "Are there any events you attended not listed above?",
     "Have any comments about this quarter's services?",
     "Have any comments about this quarter's fellowships?",
     "What committee were you in?",
     "(i.e. receipts, recycling)",
     "Which GBMs do you get full credit for?",
     "Which GBMs do you get half credit for?",
     "Anything else you'd like to share?"]
   end
end
