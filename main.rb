require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'my_secret' 

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17


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
      break if total <= BLACKJACK_AMOUNT
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

  def winner!(msg)
    @play_again = true
    @show_hit_or_stay = false
    @success = "<strong>Congratulation #{session[:player_name]} win!</strong> #{msg}"
  end


  def loser!(msg)
    @play_again = true
    @show_hit_or_stay = false
    @error = "<strong>Sorry, #{session[:player_name]} lose!</strong> #{msg}"
  end


  def tie!(msg)
    @play_again = true
    @show_hit_or_stay = false
    @success = "<strong>It's a tie!</strong> #{msg}"
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
  session[:true] = session[:player_name]
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
    if player_total == BLACKJACK_AMOUNT
      winner!("#{session[:player_name]} hit blackjack.")
    elsif player_total > BLACKJACK_AMOUNT
      loser!("#{session[:player_name]} busted at #{player_total}.")
    end
  erb :game
end


post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay"
  @show_hit_or_stay = false
  redirect '/game/dealer'
end


get '/game/dealer' do
  session[:true] = "dealer"
  @show_hit_or_stay = false
  dealer_total = calculate_total(session[:dealer_cards])
  if dealer_total == BLACKJACK_AMOUNT
    loser!("Dealer hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("Dealer busted at #{dealer_total}.")
  elsif dealer_total >= DEALER_MIN_HIT #17,18,19,20
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

get '/game/compare' do
  @show_hit_or_stay = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total > dealer_total
    winner!("#{session[:player_name]} stay #{player_total}, and the dealer stay #{dealer_total}.")
  elsif player_total < dealer_total
    loser!("#{session[:player_name]} stay #{player_total}, and the dealer stay #{dealer_total}.")
  else
    tie!("#{session[:player_name]} and the dealer both stay #{player_total}.")
  end

  erb :game
end

get '/game_over' do
  erb :game_over
end















