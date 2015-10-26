require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  "Hello world!!!!!!!"
end

get '/test' do
  @my_var = "Wendy"
  erb :test
end
