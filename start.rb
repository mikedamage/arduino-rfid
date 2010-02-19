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
		if params[:tag].size > 9
			tag = params[:tag].chomp
			user = DB[:users].filter(:rfid_tag => tag)
		
			if user.count > 0
				user_data = user.first
				LOGGER.info("RFID card swiped by user. Tag ID: #{tag}, User: #{user_data[:name]}.")
				new_scan_count = user_data[:scan_count] + 1
				user.update(:scan_count => new_scan_count, :last_scanned_at => Time.now)
			
				if user_data[:signed_in]
					time_difference = Time.now - user_data[:last_scanned_at]
					voice = `say --voice=Vicki "Goodbye, #{user_data[:name]}. You worked for #{time_difference.to_i} seconds. Thanks for working at Converge."`
					user.update(:signed_in => false)
				else
					voice = `say --voice=Vicki "Hello #{user_data[:name]}. Welcome to Converge."`
					user.update(:signed_in => true)
				end
			
				"OK"
			end
		else
			LOGGER.info("User not found for card ID #{tag}")
			"ER"
		end
	end
end