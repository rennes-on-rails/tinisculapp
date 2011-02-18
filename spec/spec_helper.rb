$LOAD_PATH.unshift(File.expand_path('../app', File.dirname(__FILE__)))
require 'rspec'
require 'rack/test'
require 'wrong/adapters/rspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

