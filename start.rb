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

post "/noise" do
	if params[:auth_key] == AUTH_KEY
		
	end
end