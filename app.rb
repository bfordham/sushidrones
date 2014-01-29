require 'sinatra'
require 'sinatra/contrib'
require './db.rb'
require 'json'

configure do
  set :db, Database.new().connect
  set :strikes, settings.db.collection('strikes')
end

helpers do
  def strike_headline(strike)
    "#{strike['deaths']} people killed in #{strike['towns']} (#{strike['location']}"
  end
  
  def strike_link(strike, text=nil)
    text = "#{strike['number']}" if text.nil?
    "<a href=\"/strikes/#{strike['number']}\">#{text}</a>"
  end

end

before /.*/ do
  if request.url.match(/.json$/)
    request.accept.unshift('application/json')
    request.path_info = request.path_info.gsub(/.json$/,'')
  end
end
    
get '/' do
  "Hi there"
end

get '/countries/?', :provides => [:html, :json] do
  @countries = settings.strikes.distinct('country')
  respond_to do |format|
    format.json { JSON.pretty_generate(@countries) }
    format.html { haml :countries }
  end
end

get '/strikes/?' do
  @strikes = settings.strikes.find.to_a
  respond_to do |format|
    format.json { JSON.pretty_generate(@strikes) }
    format.html { haml :strikes }
  end
end

get '/strikes/:id/?' do  
  content_type :json
  strike = settings.strikes.find_one({:number => params[:id].to_i})
  JSON.pretty_generate(strike)
end

