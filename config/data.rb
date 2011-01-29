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

  attr_accessor :company_name

  def submit!
    database.transaction do
      self.company, self.spelling = Company.tally(company_name)
      self.save
    end
  end

end

class Company < Sequel::Model
  one_to_many :votes
  one_to_many :spellings

  def self.find_by_pattern_or_create(spelling)
    regex = Regexp.new(spelling.gsub(/[ \-_]+/, '[ -_]*'))
    p regex.inspect
    company = Company.filter(:name.ilike(regex)).first ||
      Company.create(:name => spelling, :preferred_spelling => spelling, :votes_count => 1)
    return company
  end

  def self.tally(name)
    spelling = Spelling.eager(:company).filter(:name => name).first ||
      Spelling.new(:name => name)
    # Called from Vote#submit!, already contained in a transaction
    if spelling.company_id.nil?
      Company.find_by_pattern_or_create(name)
      company = Company.create(:name => spelling, :preferred_spelling => spelling, :votes_count => 1)
      spelling.company = company
      spelling.votes_count = 1
      spelling.save
    else
      company = spelling.company
      spelling.set(:votes_count => spelling.votes_count + 1)
      spelling.company.set(:votes_count => company.votes_count + 1)
    end

    return company, spelling
  end

end

class Spelling < Sequel::Model
  many_to_one :company
  one_to_many :votes

  def after_update
    super
    company.update_preferred_spelling
  end

end
