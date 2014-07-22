require 'bundler'
Bundler.require

# load the Database and User model
require './models'
require './drone_helpers'

class SushiDrones < Sinatra::Base
  enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    register Sinatra::RespondWith
    GMAPS_API_KEY="AIzaSyAVuun0eGe_crbBQlU90E8YOVazuBPN6OE"
  end

  use Rack::Logger

  helpers DroneHelpers, Sinatra::JSON

  before /.*/ do
    if request.url.match(/.json$/)
      request.accept.unshift('application/json')
      request.path_info = request.path_info.gsub(/.json$/,'')
    elsif request.url.match(/.js$/)
      request.accept.unshift('application/javascript')
      request.path_info = request.path_info.gsub(/.js$/,'')
    end
  end
      
  get '/' do
    @strikes = Strike.all.sort(number:-1).limit(10)
    haml :index
  end

  get '/about/?' do
    @content = RDiscount.new( File.open("contents/about.md").read ).to_html
    haml :about
  end

  get '/countries/?', :provides => [:html, :json] do
    @countries = Strike.distinct(:country)

    respond_to do |format|
      format.json { json @countries }
      format.html { haml :countries }
    end
  end

  get '/countries/:country_slug/?' do
    country_slug = params[:country_slug]
    @strikes = Strike.where(country_slug: country_slug)
    @country = @strikes.first.country
    @locations = @strikes.distinct(:location)

    respond_to do |format|
      format.json { json @strikes }
      format.html { haml :country }
      format.js { js :strike_js }
    end
  end

  get '/countries/:country_slug/:location_slug?' do
    country_slug = params[:country_slug]
    location_slug = params[:location_slug]
    @strikes = Strike.where(country_slug: country_slug, location_slug: location_slug)
    @country = @strikes.first.country
    @location = @strikes.first.location
    @towns = @strikes.distinct(:town)

    respond_to do |format|
      format.json { json @strikes }
      format.html { haml :location }
      format.js { js :strike_js }
    end
  end

  get '/countries/:country_slug/:location_slug/:town_slug/?' do
    country_slug = params[:country_slug]
    location_slug = params[:location_slug]
    town_slug = params[:town_slug]
    @strikes = Strike.where(country_slug: country_slug, location_slug: location_slug, town_slug: town_slug)
    @country = @strikes.first.country
    @location = @strikes.first.location
    @town = @strikes.first.town

    respond_to do |format|
      format.json { json @strikes }
      format.html { haml :town }
      format.js { js :strike_js }
    end
  end

  get '/strikes/?' do
    @strikes = Strike.all
    respond_to do |format|
      format.json { json @strikes }
      format.html { haml :strikes }
      format.js { js :strike_js }
    end
  end

  get '/strikes/:id/?' do  
    @strike = Strike.where(number: params[:id].to_i).first
    self.respond_to do |format|
      format.json { json @strike }
      format.html {haml :strike }
      format.js {@strikes = [@strike]; js :strike_js }
    end
    
  end

  get '/strikes/visible/?', provides: [:js] do
    lat1 = params[:lat1]
    lat2 = params[:lat2]
    lon1 = params[:lon1]
    lon2 = params[:lon2]

    unless lat1.blank? or lat2.blank? or lat3.blank? or lat4.blank?
      @visible = Strike.in_bounds(lat1, lon1, lat2, lon2)
      haml :visible
    end
  end

  protected
  def js(template)
    haml template, layout: false
  end
end

