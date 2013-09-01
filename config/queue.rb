require 'qu-sequel'

# NOTE DB_PATH defined in config/database.rb
QU_DB_PATH = File.join(DB_PATH, 'queue.db')
QU_DB_URI  = "sqlite://#{QU_DB_PATH}"

Qu.configure do |c|
  c.backend.database_url = QU_DB_URI

  # Make sure tables are created
  connection = ::Sequel.connect(QU_DB_URI)
  c.backend.class.create_tables(connection)
  connection.disconnect
end
