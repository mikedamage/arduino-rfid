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
	
	desc "add_fields", "Add meta fields to database"
	def add_fields
		require "rubygems"
		require "sequel"
		
		db = Sequel.sqlite("db/development.sqlite3")
		
		db.alter_table(:users) do
			add_column :signed_in, :boolean
		end
	end
	
	desc "seed", "Seed database with sample entries"
	def seed
		%w(rubygems sequel).each {|lib| require lib }
		# TODO: Write this method...
		true
	end
	
	desc "migrate_and_seed", "Run migrations and seed database"
	def migrate_and_seed
		migrate
		add_fields
		seed
	end
	
end