require 'rubygems'
require 'sinatra'
require 'haml'

mime_type :ttf, "application/octet-stream"
mime_type :woff, "application/octet-stream"

get '/' do
  haml :index
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
