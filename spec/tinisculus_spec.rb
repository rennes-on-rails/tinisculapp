require 'spec_helper'
require 'tinisculus'

# did not succeed in using set(:environment, :test) with app being a Sinatra::Base
# rack middleware is there :)
class FakeQuestion < Minisculus::Question
  def read; self; end
  def answer; self;end
end

describe Tinisculus do
  include Rack::Test::Methods
  let(:app) {Tinisculus.new}
  
  describe "get /" do
    it 'redirect to /challenge/1' do
      get '/'
      assert {last_response.location == 'http://example.org/start'}
    end
  end
  
  describe "get /challenge/1" do
    before do
      @question = FakeQuestion.new
      stub(Minisculus::Question).new {@question}
    end    
    it "renders challenge template" do
      get '/challenge/1'
      body = last_response.body
      assert {body =~ /Challenge #1/}
    end
  end
  
  describe "post /challenge/1" do
    let(:first) {FakeQuestion.new}
    let(:second) {FakeQuestion.new(:id => 2, :uri => 'uri#2', :message => 'message#2')}
    before do
      stub(Minisculus::Question).find('1') {first}
    end
    it "context is functional" do
      q = Minisculus::Question.find('1')
      assert {q == first}
    end
    describe "correct answer" do
      before do
        stub(first).answer! {second}
        post '/challenge/1', :answer => 'correct'
      end
      it "redirect to /challenge/2" do
        assert {last_response.location == 'http://example.org/challenge/2'}
      end
    end
    describe "incorrect response" do
      before do
        stub(first).answer! {raise Minisculus::NotAcceptable}
        post '/challenge/1', :answer => 'incorrect'
      end
      it "should render an error page" do
        assert {last_response.body =~ /incorrect answer/}
      end
    end
  end
end