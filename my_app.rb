# You'll need to require these if you
# want to develop while running with ruby.
# The config/rackup.ru requires these as well
# for it's own reasons.
#
# $ ruby heroku-sinatra-app.rb
#
require 'rubygems'
require 'sinatra'

require 'config/init.rb'

# Quick test
get '/' do
  haml :index
end

post '/vote' do
  vote = Vote.new(params).submit! or halt 400
  redirect "/thank_you/#{vote.id}"
end

get '/thank_you/:id' do
  @vote = Vote[params[:id]] if params[:id]
  haml :thank_you
end

get '/results/:id' do
  @vote = Vote[params[:id]] if params[:id]
  @companies = Company.get_by_votes
  haml :results
end

# Test at <appname>.heroku.com

# You can see all your app specific information this way.
# IMPORTANT! This is a very bad thing to do for a production
# application with sensitive information

# get '/env' do
#   ENV.inspect
# end
