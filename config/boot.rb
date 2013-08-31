$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'bundler/setup'

require 'term/ansicolor'
class String
  include Term::ANSIColor
end

require 'qu-sequel'

Qu.configure do |c|
  DB_PATH = File.join(File.dirname(__FILE__), '..', 'db', 'queue.db')
  DB_URI =  "sqlite://#{DB_PATH}"

  c.backend.database_url = DB_URI

  # Make sure tables are created
  connection = ::Sequel.connect(DB_URI)
  c.backend.class.create_tables(connection)
  connection.disconnect
end

puts "=> Bootstrapped".bold
