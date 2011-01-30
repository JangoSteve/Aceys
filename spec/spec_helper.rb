
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'rack/test'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.join(File.dirname(__FILE__), '..', 'my_app')

RSpec::Matchers.define :have_found_by_spelling do |expected_record, spelling|
  match do |actual_record|
    expected_record == actual_record
  end

  failure_message_for_should do |actual_record|
    "expected `#{spelling}` would match '#{expected_record.name}'"
  end

  failure_message_for_should_not do |actual_record|
    "expected `#{spelling}` would not match '#{expected_record.name}'"
  end
end
