require File.dirname(__FILE__) + '/spec_helper'

describe "My App" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  before :each do
    [Vote,Spelling,Company].each(&:delete)
  end

  describe "voting" do
    before :each do
      @vote = Vote.new(:company_name => 'Alfa Jango')
    end

    it "creates a new spelling and tallies vote" do
      @vote.submit!
      spelling = @vote.spelling
      spelling.should be_a(Spelling)
      spelling.name.should == @vote.company_name
      spelling.votes_count.should == 1
    end

    it "creates a new company and tallies vote" do
      @vote.submit!
      company = @vote.company
      company.should be_a(Company)
      company.votes_count.should == 1
    end

    it "associates spelling and company" do
      @vote.submit!
      spelling = @vote.spelling
      company = @vote.company
      spelling.company_id.should == company.id
    end

    describe "for existing companies" do
      before :each do
        @existing_vote = Vote.new(:company_name => 'Alfa Jango')
        @existing_vote.submit!
      end

      it "finds existing spelling and tallies vote" do
        @vote.submit!
        @vote.spelling_id.should == @existing_vote.spelling_id
        @vote.spelling.reload.votes_count.should == 2
      end

      it "finds existing company and tallies vote" do
        @vote.submit!
        @vote.company_id.should == @existing_vote.company_id
        @vote.company.reload.votes_count.should == 2
      end

      it "creates alternate spelling and tallies vote for existing company" do
        @vote.company_name = "alfa-jango"
        @vote.submit!
        @vote.spelling_id.should_not == @existing_vote.spelling_id
        @vote.company_id.should == @existing_vote.company_id
        @vote.company.reload.votes_count.should == 2
      end

      it "updates preferred spelling for existing company" do
        @vote.company_name = "Alfa-Jango"
        @vote.submit!
        @vote.company.preferred_spelling.should == "Alfa Jango"
        Vote.new(:company_name => "Alfa-Jango").submit!
        @vote.company.reload.preferred_spelling.should == "Alfa-Jango"
      end

      it "matches similar phonetic spellings" do
        pending
      end
    end

  end

  describe "spellings" do
    before :each do
      @company = Company.create(:name => "Alfa Jango LLC")
      @company2 = Company.create(:name => "IX Innovations")
    end

    it "matches common spelling variants" do
      ["Alfa Jango, LLC", "alfa jango llc", "AlfaJango llc", "alfa-jango_llc", "'Alfa' \"Jango\", LLC", "Alfa/Jango LLC"].each do |spelling|
        Company.find_by_pattern(spelling).should have_found_by_spelling @company, spelling
      end
    end
  end

  describe "results" do
    before :each do
      [
        @vote1 = Vote.new(:company_name => 'Alfa Jango'),
        Vote.new(:company_name => 'alfa-jango'),
        @vote3 = Vote.new(:company_name => 'IX Innovations'),
        Vote.new(:company_name => 'ix innovations'),
        @vote5 = Vote.new(:company_name => 'ix innovations')
      ].each(&:submit!)
    end

    it "orders results properly" do
      results = Company.get_by_votes
      results.count.should == 2
      results.first.id.should == @vote5.company_id
      results.last.id.should == @vote1.company_id
    end

    it "limits results if passed" do
      results = Company.get_by_votes(1)
      results.count.should == 1
    end

    it "re-tallies votes properly for companies" do
      @vote1.company.update(:votes_count => 200)
      @vote5.company.update(:votes_count => 300)

      @vote1.company.re_tally_votes.votes_count.should == 2
      @vote5.company.re_tally_votes.votes_count.should == 3
    end

    it "re-tallies votes properly for spellings" do
      @vote1.spelling.update(:votes_count => 200)
      @vote1.spelling.re_tally_votes.votes_count.should == 1

      @vote5.company.update(:votes_count => 300, :preferred_spelling => 'bleep bloop')
      @vote5.spelling.re_tally_votes.votes_count.should == 2
      @vote5.company.preferred_spelling.should == @vote5.company_name
    end

  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end

  it "should respond to /thank_you" do
    get '/thank_you'
    last_response.should be_ok
  end

  it "should respond to /results" do
    get '/results'
    last_response.should be_ok
  end
end
