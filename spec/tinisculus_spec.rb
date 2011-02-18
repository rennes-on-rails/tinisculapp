require 'spec_helper'
require 'tinisculus'

# did not succeed in using set(:environment, :test) with app being a Sinatra::Base
ENV['RACK_ENV'] = 'test'
def app
  Tinisculus
end

describe Tinisculus do
  describe "get /" do
    it 'redirect to /challenge/1' do
      get '/'
      assert {last_response.location == 'challenge/1'}
    end
  end
end