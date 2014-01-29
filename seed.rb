require 'open-uri'
require './db'
require 'json'

def seed
	db_connection = Database.new.connect
	strikes = db_connection.collection('strikes')

	puts "Removing current records."
	strikes.remove

	puts "Getting data from dronestre.am"
	data = JSON.parse open('http://api.dronestre.am/data').read
	puts "Found #{data['strike'].count} strikes. Inserting..."
	data['strike'].each do |strike|
		strikes.insert strike
	end

	puts "Done."
end