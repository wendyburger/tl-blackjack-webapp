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

  def card_img(card)#['H','9']
    suit = case card[0]
    when 'C' then 'clubs'
    when 'D' then 'diamonds'
    when 'H' then 'hearts'
    when 'S' then 'spades'      
    end
  
  
    value = card[1]
    if ['J','Q','K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
        end
    end
    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image' >"
  end
end


before do
  @show_hit_or_stay = true
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
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:set_name)
  end

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


post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
    if player_total == 21
      @success = "Congratulation! #{session[:player_name]} hit blackjack!"
    elsif player_total > 21
      @error = "Sorry, it looks like #{session[:player_name]} busted!"
      @show_hit_or_stay = false
    end
  erb :game
end


post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay"
  @show_hit_or_stay = false
  redirect '/game/dealer'
end


get '/game/dealer' do
  @show_hit_or_stay = false
  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == 21
    @error = "Sorry, delear hit blackjack. Dealer win"
  elsif dealer_total > 21
    @success = "Congratulation, delear busted. You win!"
  elsif dealer_total >= 17 #17,18,19,20
  #dealer stay
    redirect '/game/compare'
  else
  #dealer hit
    @show_dealer_hit_button = true

  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end















