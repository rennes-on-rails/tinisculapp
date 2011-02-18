$LOAD_PATH.unshift(File.expand_path('../app', File.dirname(__FILE__)))
require 'tinisculus'
require 'rspec'
require 'rack/test'
require 'wrong/adapters/rspec'

set(:environment, :test)

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

