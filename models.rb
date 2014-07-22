require 'mongoid'

Mongoid.load!('./mongoid.yml')

class Strike
	include Mongoid::Document
	field :n,    type: Integer,  as: :number
	field :c,    type: String,   as: :country
	field :dt,   type: DateTime, as: :date
	field :t,    type: String,   as: :town
	field :l,    type: String,   as: :location
	field :d,    type: String,   as: :deaths
	field :dl,   type: Integer,  as: :deaths_min
	field :du,   type: Integer,  as: :deaths_max
	field :civ,  type: String,   as: :civilians
	field :i,    type: String,   as: :injuries
	field :kid,  type: String,   as: :children
	field :tid,  type: String,   as: :tweet_id
	field :bid,  type: String,   as: :bureau_id
	field :bijs, type: String,   as: :bij_summary_short
	field :bijl, type: String,   as: :bij_link
	field :ta,   type: String,   as: :target
	field :lat,  type: String,   as: :lat
	field :lon,  type: String,   as: :lon
	field :art,  type: String,   as: :articles
	field :nm,   type: String,   as: :names_list
	field :cs,   type: String,   as: :country_slug
	field :ls,   type: String,   as: :location_slug
	field :ts,   type: String,   as: :town_slug

	# Finds strikes within a bounding box
	def self.in_bounds(lat1, lon1, lat2, lon2)
		if lat1 < lat2
			latgte = lat1
			latlte = lat2
		else
			latgte = lat2
			latlte = lat1
		end

		if lon1 < lon2
			longte = lon1
			lonlte = lon2
		else
			longte = lon2
			lonlte = lon1
		end

		strikes = {}
		Strike.where(:lat.gte => latgte, :lat.lte =>latlte, :lon.gte => longte, :lon.lte => lonlte).each do |strike|
			key = [strike.lat, strike.lon]
			# do we already have one at these coordinates?
			if strikes.has_key? key
				# increment it
				strikes[key][:count] = strikes[key][:count] + 1
			else
				# store the info
				strikes[key] = {
					:lat => strike.lat,
					:lon => strike.lon,
					:town => strike.town,
					:location => strike.location,
					:country => strike.country,
					:count => 1
				}
			end
		end
		return strikes

	end

	def self.sluggify(text)
		text.downcase.gsub(' ', '-')
	end

	def headline(skip_link=false)
		h = "#{deaths} people killed in #{town}"
		h = h + " (#{location_link})" unless skip_link
		return h
	end

	def link(text=nil)
		text = "#{number}" if text.nil?
		"<a href=\"/strikes/#{number}\">#{text}</a>"
	end

	def format_date
		date.strftime('%e %B, %Y')
	end

	# Returns set of all Strikes at these coordinates
	def same_place
		Strike.where(lat: lat, lon:lon)
	end

	def location_link
		"<a href=\"/countries/#{Strike.sluggify country}/#{Strike.sluggify location}\">#{location}</a>"
	end

	def country_link
		"<a href=\"/countries/#{Strike.sluggify country}\">#{country}</a>"
	end

	def to_js_obj
		data = {}
		[:number, :country, :location, :town, :lat, :lon].each do |attr|
			data[attr] = send(attr)
		end
		data[:headline] = headline(true)
		return data
	end
end