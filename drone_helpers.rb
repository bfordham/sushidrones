module DroneHelpers
	def sluggify(text)
		text.downcase.gsub(' ', '-')
	end

	def country_link(country, text=nil)
		text = country if text.nil?
		"<a href=\"#{country_url(country)}\">#{text}</a>"
	end

	def location_link(country, location, text=nil)
		text = location if text.nil?
		"<a href=\"#{location_url(country, location)}\">#{text}</a>"
	end

	def town_link(country, location, town, text=nil)
		text = town if text.nil?
		"<a href=\"#{town_url(country, location, town)}\">#{text}</a>"
	end

	def country_url(country)
		"/countries/#{sluggify(country)}"
	end

	def location_url(country, location)
		"/countries/#{sluggify country}/#{sluggify location}"
	end

	def town_url(country, location, town)
		"/countries/#{sluggify country}/#{sluggify location}/#{sluggify town}"
	end
end