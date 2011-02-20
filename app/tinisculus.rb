require 'rubygems'
require 'sinatra/base'
require 'haml'
require "#{File.dirname(__FILE__)}/models/question"

class Tinisculus < Sinatra::Base
  mime_type :ttf, "application/octet-stream"
  mime_type :woff, "application/octet-stream"
  
  set :root, File.dirname(__FILE__)
  disable :show_exceptions
  
  get '/challenge/:id' do |id|
    @question = Minisculus::Question.find(id).read
    haml :challenge
  end

  post '/challenge/:id' do |id|
    @question = Minisculus::Question.find(id).read
    @question = @question.answer!(params[:answer]).read
    redirect "/challenge/#{@question.id}"
  end

  get '/start' do
    haml :start
  end
  
  get '/' do
    redirect '/start'
  end
  
  # errors at bottom ?
  error Minisculus::NotAcceptable do
    haml :try_again
  end
end
