require "logger"
require "rubygems"
require "sequel"
require "digest/sha1"
require "sinatra"

configure do
	DB = Sequel.sqlite("db/development.sqlite3")
	AUTH_KEY = Digest::SHA1.hexdigest("fifthroom")[0..10]
	LOGGER = Logger.new("log/development.log")
	LOGGER.level = Logger::INFO
end

post "/noise_error" do
	if params[:auth_key] == AUTH_KEY
		LOGGER.info("Received random radio noise.")
	end
end

post "/tag" do
	if params[:auth_key] == AUTH_KEY
		tag = params[:tag].chomp
		user = DB[:users].filter(:rfid_tag => tag)
		
		if user.count > 0
			user_data = user.first
			LOGGER.info("RFID card swiped by user. Tag ID: #{tag}, User: #{user_data[:name]}.")
			new_scan_count = user_data[:scan_count] + 1
			user.update(:scan_count => new_scan_count, :last_scanned_at => Time.now)
			voice = `say "Hello #{user_data[:name]}. Welcome to Converge."`
			"OK"
		else
			LOGGER.info("User not found for card ID #{tag}")
			"ER"
		end
	end
end