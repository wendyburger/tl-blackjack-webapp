require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'my_secret' 


get '/' do
  erb :set_name
end


#Don't use @name = params[:player_name], when redirect, data will missing
#Use session[:player_name] = params[:player_name], data storage in cookies
post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/bet'
end


get '/bet' do
  erb :bet
end


post '/bet' do
  session[:a_bet] = params[:a_bet]
  redirect '/show_cost'
end


get '/show_cost' do
  erb :show_cost
end


get '/game' do
  session[:deck] = [['2', 'H'], ['8', 'D']]
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  erb :game
end



get '/mytemplate' do
  redirect "/myprofile"  
end

get '/myprofile' do
  erb :"/users/profile"
end
