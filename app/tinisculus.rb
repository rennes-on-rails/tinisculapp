require 'rubygems'
require 'sinatra/base'
require 'haml'
require "#{File.dirname(__FILE__)}/models/challenge"

class Tinisculus < Sinatra::Base
  set :root, File.dirname(__FILE__)

  get '/challenge/:number' do |number|
    @number = Integer(number)
    haml :challenge
  end

  post '/challenge/:id' do |id|
    index = Integer(id)
    if Challenge.correct?(index, params[:answer])
      index = Challenge.next index
      redirect index ? "/challenge/#{index}" : "/end"
    else
      haml :try_again
    end
  end

  get '/end' do
    haml :end
  end

  get '/' do
    redirect '/challenge/1'
  end
end
