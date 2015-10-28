require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'my_secret' 


helpers do
  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    
    arr.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i 
      end
    end

    #Ace correct
    arr.select{|element| element == "A"}.count.times do
      break if total <= 21
      total -= 10
    end

    total

  end
end


get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/set_name'
  end
end

get '/set_name' do
  erb :set_name
end


#Don't use @name = params[:player_name], when redirect, data will missing
#Use session[:player_name] = params[:player_name], data storage in cookies
post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end



get '/game' do
  #create a deck in a session
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle!
  
  #deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  
  erb :game
end


post 'game' do
  
end












