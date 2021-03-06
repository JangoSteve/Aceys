module Voteable
  def self.included(base)
    base.one_to_many :votes
    unless base.respond_to?(:add_association_dependencies)
      base.plugin :association_dependencies
    end
    base.add_association_dependencies :votes => :delete
    base.extend ClassMethods
  end

  module ClassMethods
    def get_by_votes(limit=nil)
      self.order(:votes_count.desc).limit(limit)
    end
  end

  def re_tally_votes
    assoc_key = self.class.association_reflection(:votes)[:key]
    votes_count = Vote.filter(assoc_key => self[primary_key]).count
    self.update(:votes_count => votes_count)
    return self
  end

  def increment_votes
    if self.new?
      self.votes_count = 1
    else
      self.this.update(:votes_count => :votes_count + 1)
    end
  end

  def decrement_votes
    if self.new?
      self.votes_count = 0
    else
      self.this.update(:votes_count => :votes_count - 1)
    end
  end

  def before_create
    self.votes_count = 0 if self.votes_count.nil?
  end

end

module Spellable

  PUNCTUATION_REGEX = /[ \-_,\'\"\/\.]+/
  PHONETIC_EQUIVALENCES = {
    'f' => [
      /(ph)/, /f{2}/
    ],
    's' => [
      /c[aeiouy]/, /s{2}/
    ],
    'k' => [
      /c^[aeiouy]/
    ]
  }
  CORPORATE_EQUIVALENCES = /\s(incorporated|corporation|p?llc|co(rp)?|inc)/

  def normalize!
    # using self.downcase! returns nil if no changes were made, instead of unaltered string, so we can't chain it
    self.downcase!

    self.
      gsub!(CORPORATE_EQUIVALENCES, '')

    PHONETIC_EQUIVALENCES.each do |canonical,equivalent|
      equivalent.each do |regex|
        self.gsub!(regex,canonical)
      end
    end

    self.gsub!(PUNCTUATION_REGEX, '')
    return self
  end
end

class String
  include Spellable
end

class Vote < Sequel::Model
  many_to_one :company
  many_to_one :spelling

  attr_accessor :company_name

  def submit!
    database.transaction do
      self.spelling = Spelling.tally(company_name)
      self.company = self.spelling.company
      self.save
    end
  end

  def before_destroy
    self.company.re_tally_votes
    self.spelling.re_tally_votes
  end

end

class Company < Sequel::Model
  include Voteable
  include Spellable

  one_to_many :spellings

  Company.add_association_dependencies :spellings => :delete

  def self.find_by_pattern_or_create(spelling)
    company =  Company.find_by_pattern(spelling) ||
      Company.create(:name => spelling, :preferred_spelling => spelling)

    return company
  end

  def self.find_by_pattern(spelling)
    #regex = Regexp.new(spelling.gsub(PUNCTUATION_REGEX, '[ -_,\'\"]*'))
    #Company.filter(:name.ilike(regex)).first
    # ^^ No longer need to search by regex, could probably go back to using sqlite for test env ^^
    normalized_spelling = spelling.clone.normalize!
    Company.filter(:name.ilike(normalized_spelling)).first
  end

  def update_preferred_spelling
    spelling = Spelling.most_popular_for(self)
    self.update(:preferred_spelling => spelling.name)
  end

  # Normalize all company names to make it easier to regex various spellings and formats
  def before_create
    # Cloned so we can pass objects as name parameter to new Company
    self.name = self.name.clone.normalize!
    super
  end

end

class Spelling < Sequel::Model
  include Voteable

  many_to_one :company

  def self.tally(company_name)
    spelling = Spelling.eager(:company).filter(:name => company_name).first ||
      Spelling.new(:name => company_name)

    # Called from Vote#submit!, already contained in a transaction
    spelling.company ||= Company.find_by_pattern_or_create(company_name)
    spelling.increment_votes
    spelling.company.increment_votes

    if spelling.new?
      spelling.save
    else
      spelling.company.update_preferred_spelling
    end

    spelling.company.reload
    return spelling
  end

  def self.most_popular_for(company)
    Spelling.filter(:company_id => company.id).order(:votes_count.desc).limit(1).first
  end

  def before_destroy
    company = self.company.eager(:spellings)
    if company.spellings.size == 1
      company.destroy
    else
      company.re_tally_votes
    end
  end

  def re_tally_votes
    super
    self.company.update_preferred_spelling
    return self
  end

end
