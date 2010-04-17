# module: app

class App < Thor
	include Thor::Actions
	
	desc "seed", "Create database and seed with sample data"
	def seed
		#%w(rubygems sequel).each {|lib| require lib }
		say "Entering ./db"
		Dir.chdir("db")
		
		say "Loading SQL dump into SQLite3 database"
		`sqlite3 development.sqlite3 < development.sql`
		
		say "Done"
	end
	
end