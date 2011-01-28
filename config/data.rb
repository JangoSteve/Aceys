# Sample code borrowed from https://github.com/Mercurius3/vrijewadlopers/blob/master/config/data.rb
# 
# class Calendar < Sequel::Model
#   calenders = database[:calendars]
#   calenders.delete
#
#   many_to_one :tour
# end
#
# class Tour < Sequel::Model
#   tours = database[:tours]
#   tours.delete
#
#   one_to_many :calendars
# end
#
# def createTour(info,dates)
#   tour = Tour.create(info)
#   dates.each do |date,info|
#     calendar = Calendar.create(:date => date, :info => info)
#     tour.add_calendar(calendar)
#     calendar.save
#   end
#   tour.save
# end

class Vote < Sequel::Model
  many_to_one :company
  many_to_one :spelling

  attr_accessor :company_name, :spelling_name

  def submit_vote!(company_name, email=nil)
    transaction do
      self.spelling = Spelling.tally(company_name)
      self.company = Company.tally(spelling)
      self.create
    end
  end

end

class Company < Sequel::Model
  one_to_many :votes
  one_to_many :spellings

  def self.tally(spelling)
    
  end
end

class Spelling < Sequel::Model
  many_to_one :company
  one_to_many :votes

  def self.tally
    Spelling.find_or_create(:name => name)
    self.company ||= Company.find_by_pattern_or_create(name)

  end

  def after_save
    super
    company.update_preferred_spelling
  end

end
