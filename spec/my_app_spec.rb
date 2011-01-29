require File.dirname(__FILE__) + '/spec_helper'

describe "My App" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  describe "voting" do
    before :each do
      [Vote,Spelling,Company].each(&:delete)
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
      company.name.should == @vote.company_name
      company.preferred_spelling.should == @vote.company_name
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

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
end
