require 'typhoeus'
require 'yajl'

class Question
  attr_accessor :number, :solution
  def initialize(hash={})
    hash.each do |k, v|
      self.send("#{k}=", v)
    end
  end
end


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
    attr_accessor :params, :instructions, :message, :code
    attr_reader :id, :md5, :last_answer
    def initialize(hash={})
      self.params = Question.default_params
      {:md5 => '14f7ca5f6ff1a5afb9032aa5e533ad95', :id => 1}.merge(hash).each_pair do |attr, val|
        self.send("#{attr}=", val)
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
        Question.new(:md5 => response.headers_hash['Location'], :id => (id+1))
      else
        raise Minisculus::NotAcceptable.new(response.code, response.body)
      end
    end

    def md5=(md5)
      @md5 = squeeze_leading_slash(md5 || '14f7ca5f6ff1a5afb9032aa5e533ad95')
    end

    def minisculus_uri
      "#{Question.eden}/#{@md5}"
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

    @@questions = [
      {md5: '14f7ca5f6ff1a5afb9032aa5e533ad95', solution: 'Yzxutm5TK5cotjy2'},
      {md5: '2077f244def8a70e5ea758bd8352fcd8', solution: 'Wkh2Ghvhuw2Ir.2zloo2pryh2632wdqnv2wr2Fdodlv2dw2gdzq'},
      {md5: '36d80eb0c50b49a509b49f2424e8c805', solution: %(JMl0kBp?20QixoivSc.2"vvmls8KOk"0jA,4kgt0OmUb,pm.)}
    ]

    class << self
      URIS = {
        '1' => '14f7ca5f6ff1a5afb9032aa5e533ad95',
        '2' => '2077f244def8a70e5ea758bd8352fcd8',
        '3' => '36d80eb0c50b49a509b49f2424e8c805',
        '4' => '4baecf8ca3f98dc13eeecbac263cd3ed',
        '5' => 'finish/50763edaa9d9bd2a9516280e9044d885'
      }
      def find(id)
        index = Integer(id) - 1
        Question.new(:id => id, :md5 => @@questions[index][:md5])
      end
      def default_params
        {:headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}}
      end
      def eden
        'http://minisculus.edendevelopment.co.uk'
      end
      def correct?(number, response)
        index = Integer(number) - 1
        response == @@questions[index][:solution]
      end
    end
  end
end
