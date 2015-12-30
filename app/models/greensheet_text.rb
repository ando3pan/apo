class GreensheetText < ActiveRecord::Base
  def self.titles
    ["Changed event type", "Other events", 
    "Committee",
    "Other Fundraising Credits", "GBM Full Attendance", 
    "GBM Half Attendance", "Final Thoughts"]
  end

  def self.descriptions
    ["If you changed an event's type to \"Other\", please list which event and
     what you want to change it to",
     "Are there any events you attended not listed above?",
     "What committee were you in?",
     "(i.e. receipts, recycling)",
     "Which GBMs do you get full credit for?",
     "Which GBMs do you get half credit for?",
     "Anything else you'd like to share?"]
   end
end
