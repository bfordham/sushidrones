require 'sinatra'
require 'sinatra/contrib'
require './db.rb'
require './helpers.rb'
require 'json'
require 'haml'

configure do
  set :db, Database.new().connect
  set :strikes, settings.db.collection('strikes')
end

before /.*/ do
  if request.url.match(/.json$/)
    request.accept.unshift('application/json')
    request.path_info = request.path_info.gsub(/.json$/,'')
  end
end
    
get '/' do
  haml :index
end

get '/countries/?', :provides => [:html, :json] do
  @countries = []
  settings.strikes.distinct('country').each do |c|
    @countries << settings.strikes.find_one(:country => c)
  end
  respond_to do |format|
    format.json { JSON.pretty_generate(@countries) }
    format.html { haml :countries }
  end
end

get '/countries/:country_slug/?' do
  @country = find_by_slug params
  @locations = find_locations(@country)
  @strikes = find_strikes(country: @country['country'])

  respond_to do |format|
    format.json { JSON.pretty_generate(@strikes) }
    format.html { haml :country }
  end
end

get '/countries/:country_slug/:location_slug?' do
  @location = find_by_slug params
  @strikes = find_strikes(country: @location['country'], location: @location['location'])
  @towns = find_towns(@location)

  respond_to do |format|
    format.json { JSON.pretty_generate(@strikes) }
    format.html { haml :location }
  end
end

get '/countries/:country_slug/:location_slug/:town_slug/?' do
  @town = find_by_slug params
  @strikes = find_strikes(country: @town['country'], location: @town['location'], town: @town['town'])

  respond_to do |format|
    format.json { JSON.pretty_generate(@strikes) }
    format.html { haml :town }
  end
end

get '/strikes/?' do
  @strikes = find_strikes
  respond_to do |format|
    format.json { JSON.pretty_generate(@strikes) }
    format.html { haml :strikes }
  end
end

get '/strikes/:id/?' do  
  @strike = settings.strikes.find_one({:number => params[:id].to_i})
  respond_to do |format|
    format.json { JSON.pretty_generate(@strike) }
    format.html {haml :strike }
  end
  
end

