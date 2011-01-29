require File.dirname(__FILE__) + '/spec_helper'

describe "My App" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
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
      company.name.should == @vote.company_name
      company.votes_count.should == 1
    end

    it "associates spelling and company" do
      @vote.submit!
      spelling = @vote.spelling
      company = @vote.company
      spelling.company_id.should == company.id
    end

    it "finds existing spelling and tallies vote" do
      pending
    end

    it "finds existing company and tallies vote" do
      pending

    end

    it "creates alternate spelling and tallies vote for existing company" do
      pending

    end

    it "updates preferred spelling for existing company" do
      pending

    end

  end

  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
end
