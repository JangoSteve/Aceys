require 'sinatra/sequel'
# switch to postgres for Heroku

configure :development do
  #set :database, 'sqlite://development/aceys.db'
  set :database, 'postgres://localhost/aceys-dev'
  require 'sqlite3'
end
configure :test do
  #set :database, 'sqlite::memory:'
  set :database, 'postgres://localhost/aceys-test'
  # rspec context looks for views relative to /spec dir unless specified
  set :views, File.dirname(__FILE__) + '/../views'
end
configure :production do
  Sequel.connect(ENV['DATABASE_URL'])

  TheDomain = 'http://www.theaceys.com'

  before do
    if request.env['HTTP_HOST'] != TheDomain
      redirect TheDomain
    end
  end
end

require 'config/migrations'

#Add our data (tours & dates) from the file config/data.rb
require 'config/data'

