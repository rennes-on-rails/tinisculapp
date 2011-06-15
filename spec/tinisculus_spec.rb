require 'spec_helper'
require 'tinisculus'

# did not succeed in using set(:environment, :test) with app being a Sinatra::Base
# rack middleware is there :)

describe Tinisculus do
  include Rack::Test::Methods
  let(:app) {Tinisculus.new}

  describe "get /" do
    it 'redirect to /challenge/1' do
      get '/'
      assert {last_response.location == 'http://example.org/challenge/1'}
    end
  end

  describe "get /challenge/1" do
    it "renders challenge template" do
      get '/challenge/1'
      body = last_response.body
      assert {body =~ /YOUR FIRST CHALLENGE/}
    end
  end

  describe "post /challenge/1" do
    describe "correct answer" do
      it "redirects to /challenge/2" do
        post '/challenge/1', :answer => 'Yzxutm5TK5cotjy2'
        assert {last_response.location == 'http://example.org/challenge/2'}
      end
    end
    describe "incorrect response" do
      it "should render an error page" do
        post '/challenge/1', :answer => 'incorrect'
        assert {last_response.body =~ /incorrect answer/}
      end
    end
  end
end