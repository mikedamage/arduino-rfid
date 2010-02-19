require "rubygems"
require "sequel"
require "digest/sha1"
require "sinatra"

configure do
	DB = Sequel.sqlite("db/development.sqlite3")
	AUTH_KEY = Digest::SHA1.hexdigest("fifthroom")[0..10]
end

post "/noise" do
	
end