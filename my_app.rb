# You'll need to require these if you
# want to develop while running with ruby.
# The config/rackup.ru requires these as well
# for it's own reasons.
#
# $ ruby heroku-sinatra-app.rb
#
require 'rubygems'
require 'sinatra'
require 'cgi'
require 'sinatra/content_for'

require 'config/init.rb'

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['steve', 'theaceysarelegit11']
  end

  def results_link(vote_id)
    "/results/#{vote_id}"
  end

  def results
    @companies = Company.get_by_votes
    @leaders = @companies.first(5).reverse # needed to plot from top to bottom in jqplot bar graph
    total_votes = Vote.count
    @leaders.each{ |l| l.votes_count /= (total_votes/100.0) }
    haml :results
  end

  def thank_you
    haml :thank_you
  end

end


# Quick test
get '/' do
  session[:blah] = "yes"
  @company_names = Company.select(:preferred_spelling).order(:preferred_spelling).collect(&:preferred_spelling)
  haml :index
end

post '/vote/?' do
  unless session[:vote_id] && ! session[:allow_multiple_votes]
    #params.merge!(:ip_address => request.ip)
    vote = Vote.new(params).submit! or halt 400
    session[:vote_id] = vote.id
    redirect "/thank_you/#{vote.id}"
  else
    redirect "/already_voted"
  end
end

get '/thank_you/?' do
  @link = "/results"
  thank_you
end

get '/thank_you/:id' do
  @vote = Vote[params[:id]]
  @link = results_link(@vote.id)
  thank_you
end

get '/already_voted/?' do
  @vote = Vote.eager(:company).filter(:id => session[:vote_id]).first
  @link = results_link(@vote.id)
  haml :already_voted
end

get '/results/?' do
  results
end

get '/results/:id' do
  @vote = Vote.eager(:company).filter(:id => params[:id]).first
  results
end

get '/authenticate/?' do
  protected!
  session[:allow_multiple_votes] = true
  redirect '/'
end



# Test at <appname>.heroku.com

# You can see all your app specific information this way.
# IMPORTANT! This is a very bad thing to do for a production
# application with sensitive information

# get '/env' do
#   ENV.inspect
# end
