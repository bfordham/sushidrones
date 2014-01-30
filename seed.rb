require 'open-uri'
require './db'
require 'json'

def sluggify(text)
	text.downcase.gsub(' ', '+')
end

def seed
	db_connection = Database.new.connect
	strikes = db_connection.collection('strikes')

	puts "Removing current records."
	strikes.remove

	puts "Getting data from dronestre.am"
	data = JSON.parse open('http://api.dronestre.am/data').read
	puts "Found #{data['strike'].count} strikes. Inserting..."
	data['strike'].each do |strike|
		# create slugs
		['country', 'location', 'town'].each do |s|
			strike["#{s}_slug"] = sluggify(strike[s]) if strike[s]
		end
		strikes.insert strike
	end

	puts "Done."
end