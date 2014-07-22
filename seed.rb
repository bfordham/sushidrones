require 'open-uri'
require './models'
require 'json'

@mapping = {
	'number' => 'n',
	'country' => 'c',
	'date' => 'dt',
	'town' => 't',
	'location' => 'l',
	'deaths' => 'd',
	'deaths_min' => 'dl',
	'deaths_max' => 'du',
	'civilians' => 'civ',
	'injuries' => 'i',
	'children' => 'kid',
	'tweet_id' => 'tid',
	'bureau_id' => 'bid',
	'bij_summary_short' => 'bijs',
	'bij_link' => 'bijl',
	'target' => 'ta',
	'lat' => 'lat',
	'lon' => 'lon',
	'articles' => 'art',
	'names_list' => 'nm',
}

def sluggify(text)
	text.downcase.gsub(' ', '-')
end

def seed
	puts "Removing current records."
	Strike.delete_all

	puts "Getting data from dronestre.am"
	data = JSON.parse open('http://api.dronestre.am/data').read
	puts "Found #{data['strike'].count} strikes. Inserting..."
	data['strike'].each do |tmp|
		# create attributes using mapping
		attrs = {}
		@mapping.each do |k,v|
			attrs[v] = tmp[k]
		end

		# create slugs
		['country', 'location', 'town'].each do |s|
			tmp[s] = "- none -" if tmp[s].blank?
			attrs["#{s.first}s"] = sluggify(tmp[s]) if tmp[s]
		end
		strike = Strike.new
		strike.attributes = attrs
		strike.save
	end

	puts "Done."
end