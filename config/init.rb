require 'sinatra/sequel'
# switch to postgres for Heroku

configure :development do
  #set :database, 'sqlite://development/aceys.db'
  set :database, 'postgres://localhost/aceys-dev'
  require 'sqlite3'

  TheDomain = 'localhost:9292'
  AuthCredentials = ['admin', 'password']

  enable :sessions
  #use Rack::Session::Cookie, :key => 'rack.session',
  #                         :domain => TheDomain,
  #                         :path => '/',
  #                         :expire_after => 300, # 5 minutes, in seconds
  #                         :secret => 'change_me'

end
configure :test do
  #set :database, 'sqlite::memory:'
  set :database, 'postgres://localhost/aceys-test'
  # rspec context looks for views relative to /spec dir unless specified
  set :views, File.dirname(__FILE__) + '/../views'
end
configure :production do
  Sequel.connect(ENV['DATABASE_URL'])

  TheDomain = 'www.theaceys.com'

  # On Heroku, set this with the heroku gem:
  # >$ heroku config:add AUTH_USER=someuser AUTH_PASSWORD=somepassword
  AuthCredentials = [ ENV['AUTH_USER'] || 'admin', ENV['AUTH_PASSWORD'] || 'password']

  before do
    if request.env['HTTP_HOST'] != TheDomain
      redirect request.scheme + '://' + TheDomain + request.path, 301
    end
  end

  enable :sessions
  #use Rack::Session::Cookie, :key => 'rack.session',
  #                         :domain => TheDomain,
  #                         :path => '/',
  #                         :expire_after => 86400, # 1 day, in seconds
  #                         :secret => 'aceysarelegit11'

end

require 'config/migrations'

#Add our data (tours & dates) from the file config/data.rb
require 'config/data'

