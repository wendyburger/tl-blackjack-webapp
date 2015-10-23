require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  "Hello world!!!!!!!"
end

get '/test' do
  "From the testing action!" + params[:some].to_s
end
