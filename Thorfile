# module: app

class App < Thor
	include Thor::Actions
	
	desc "migrate", "Migrate the database schema"
	def migrate
		require "rubygems"
		require "sequel"
		
		db = Sequel.sqlite("db/development.sqlite3")
		
		db.create_table(:users) do
			primary_key :id, :type => Integer
			String :name
			String :rfid_tag, :size => 10
			Fixnum :scan_count
			DateTime :last_scanned_at
		end
	end
	
end