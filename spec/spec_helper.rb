$LOAD_PATH.unshift(File.expand_path('../app', File.dirname(__FILE__)))
ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'wrong/adapters/rspec'
RSpec.configure do |conf|
  conf.mock_with(:rr)
end

