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

require 'config/init.rb'

# Quick test
get '/' do
  haml :index
end

post '/vote/?' do
  vote = Vote.new(params).submit! or halt 400
  redirect "/thank_you/#{vote.id}"
end

get '/thank_you/?' do
  @link = "/results"
  thank_you
end

get '/thank_you/:id' do
  @vote = Vote[params[:id]]
  @link = "/results/#{@vote.id}"
  thank_you
end

get '/results/?' do
  results
end

get '/results/:id' do
  @vote = Vote[params[:id]]
  results
end

def results
  @companies = Company.get_by_votes
  haml :results
end

def thank_you
  haml :thank_you
end

# Test at <appname>.heroku.com

# You can see all your app specific information this way.
# IMPORTANT! This is a very bad thing to do for a production
# application with sensitive information

# get '/env' do
#   ENV.inspect
# end
