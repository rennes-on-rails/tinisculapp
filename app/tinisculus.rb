require 'rubygems'
require 'sinatra/base'
require 'haml'

class Tinisculus < Sinatra::Base
  mime_type :ttf, "application/octet-stream"
  mime_type :woff, "application/octet-stream"
  
  set :root, File.dirname(__FILE__)

  get '/' do
    redirect '/challenge/1'
  end
end

# post '/working' do
#   if GITHUB_HANDLES.include?(params[:handle])
#     erb :yes
#   else
#     erb :no
#   end
# end
# 
# get '/yes' do
#   erb :yes
# end
# 
# get '/no' do
#   erb :no
# end
