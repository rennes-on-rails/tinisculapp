require 'spec_helper'
require 'models/question'

describe Minisculus::Question do
  describe Minisculus::NotAcceptable do
    it 'to_s should have code' do
      assert {Minisculus::NotAcceptable.new(719, 'nuked').to_s =~ /\(code : 719\)/}
    end
  end
  
  describe '.default_params' do
    it 'should set accept and content type as json' do
      assert {Minisculus::Question.default_params[:headers]['Accept'] == 'application/json'}
      assert {Minisculus::Question.default_params[:headers]['Content-Type'] == 'application/json'}
    end
  end
  
  describe "#initialize" do
    it "when not providing uri in constructor it is first question from minisculus site" do
      q = Minisculus::Question.new
      assert {q.uri == '14f7ca5f6ff1a5afb9032aa5e533ad95'} 
      assert {q.id == 1} 
    end
    it 'when providing id as a string, then id is converted to Integer' do
      q = Minisculus::Question.new(:id => '23')
      assert {q.id == 23}
    end
  end
  
  describe '#read' do
    let(:question) {Minisculus::Question.new(:uri => '/1')}
    
    it 'get page from minisculus site' do
      url, message = "oh", "ha"
      mock(Typhoeus::Request).get(question.minisculus_uri, question.params) {
        Typhoeus::Response.new(:body => "{\"reference-url\":\"#{url}\",\"question\":\"#{message}\"}")
      }

      question.read()

      assert {question.instructions == "#{Minisculus::Question.eden}/oh"}
      assert {question.message == 'ha'}
    end
  end
  
  describe "uri and minisculus_uri" do
    let(:question) {Minisculus::Question.new(:uri => '234')}
    it {assert {question.minisculus_uri == "#{Minisculus::Question.eden}/234"}}
    it {assert {question.uri == '234'}}
  end
  
  describe '#answer!' do
    let(:question) {
      Minisculus::Question.new(:uri => '/234').tap{|q| q.message = 'ha'}
    }
    describe "puts to minisculus site, as json" do
      it 'with block, content is block instance evaled' do
        content = '{"answer":"ha"}'
        mock(Typhoeus::Request).put(question.minisculus_uri, question.params.merge(:body => content)) {
          Typhoeus::Response.new(:code => 303)
        }
        question.answer! {message}
      end
      it 'with arg, content is block instance evaled' do
        content = '{"answer":"ha"}'
        mock(Typhoeus::Request).put(question.minisculus_uri, question.params.merge(:body => content)) {
          Typhoeus::Response.new(:code => 303)
        }
        question.answer! 'ha'
      end      
    end
    
    describe 'when response is redirect' do
      before do
        mock(Typhoeus::Request).put(anything, anything) {
          Typhoeus::Response.new(:code => 303, :headers_hash => {'Location' => '/next-question'})
        }
      end
      it 'should return a new question, having an incremented id' do
        next_question = question.answer! {}
        assert {next_question.uri == 'next-question'}
        assert {next_question.id == question.id + 1}
      end
    end
    
    describe 'when response is not accepted' do
      before do        
        mock(Typhoeus::Request).put(anything, anything) {
          Typhoeus::Response.new(:code => 418)
        }
      end
      it 'should raise' do
        error = rescuing {question.answer!}
        assert {error.class == Minisculus::NotAcceptable}
        assert {error.message =~ /check you post to correct url/}
        assert {error.code == 418}
      end
    end
  end
  
  describe "find by id" do
    let(:questions) {{
      1 => '14f7ca5f6ff1a5afb9032aa5e533ad95',
      2 => '2077f244def8a70e5ea758bd8352fcd8', 
      3 => '36d80eb0c50b49a509b49f2424e8c805'
    }}
    it "return question by id in range (1..3)" do
      questions.each_pair do |id, uri|
        q = Minisculus::Question.find(id)
        assert {q.uri == uri}
        assert {q.id == id}
      end
    end
  end
end