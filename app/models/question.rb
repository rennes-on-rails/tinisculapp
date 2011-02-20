require 'typhoeus'
require 'yajl'

module Minisculus
  class NotAcceptable < StandardError
    attr_reader :code
    def initialize(code=406, message=nil)
      message ||= 'No message provided by minisculus, check you post to correct url ?'
      super("#{message} (code : #{code})")
      @code = code
    end
  end
  
  class Question    
    # core
    attr_accessor :params, :instructions, :message, :code
    attr_reader :id, :uri, :last_answer
    def initialize(hash={})
      self.params = Question.default_params
      {:uri => '14f7ca5f6ff1a5afb9032aa5e533ad95', :id => 1}.merge(hash).each_pair do |attr, val|
        self.send("#{attr}=".to_sym, val) 
      end
    end
    
    def id=(id)
      @id = id.is_a?(Fixnum) ? id : Integer(id)
    end
    
    def read
      s = Typhoeus::Request.get(minisculus_uri, params).body
      hash = Yajl::Parser.new.parse(s)
      self.instructions = squeeze_leading_slash(hash['reference-url'])
      self.message = hash['question']
      self.code = hash['code']
      self
    end
    
    def answer!(answer=nil, &block)
      @last_answer = block.nil?? answer : self.instance_eval(&block)
      body = Yajl::Encoder.encode({'answer' => @last_answer})
      puts "#{self} answers #{body}" if params[:verbose]
      response = Typhoeus::Request.put(minisculus_uri, params.merge(:body => body))
      case response.code
      when 303
        Question.new(:uri => response.headers_hash['Location'], :id => (id+1))
      else
        raise Minisculus::NotAcceptable.new(response.code, response.body)
      end
    end

    def uri=(uri)
      @uri = squeeze_leading_slash(uri || '14f7ca5f6ff1a5afb9032aa5e533ad95')
    end
    
    def minisculus_uri
      "#{Question.eden}/#{@uri}"
    end
    
    def instructions
      "#{Question.eden}/#{@instructions}"
    end
    
    def show
      require 'launchy'
      Launchy.open(instructions) if @instructions
    end
    
    private
    def squeeze_leading_slash(s)
      s = s[1..-1] if s[0] == '/'
      s
    end
    
    class << self
      URIS = {
        '1' => '14f7ca5f6ff1a5afb9032aa5e533ad95',
        '2' => '2077f244def8a70e5ea758bd8352fcd8', 
        '3' => '36d80eb0c50b49a509b49f2424e8c805'
      }
      def find(id)
        (uri = URIS[id.to_s]) ? Question.new(:id => id, :uri => uri) : nil
      end
      def default_params
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}}
      end
      def eden
        'http://minisculus.edendevelopment.co.uk'
      end      
    end
  end
  
  # answers = {
  #   1 => {:uri => '14f7ca5f6ff1a5afb9032aa5e533ad95', :answer => 'Yzxutm5TK5cotjy2'},
  #   2 => {:uri => '2077f244def8a70e5ea758bd8352fcd8', :answer => 'Wkh2Ghvhuw2Ir.2zloo2pryh2632wdqnv2wr2Fdodlv2dw2gdzq'},
  #   3 => {:uri => '36d80eb0c50b49a509b49f2424e8c805', :answer => %{JMl0kBp?20QixoivSc.2"vvmls8KOk"0jA,4kgt0OmUb,pm.}}
  # }
end
