require 'sequel'

DB_PATH = File.join(APP_ROOT, 'db')
FileUtils.mkdir_p(DB_PATH)

DB = Sequel.connect("sqlite://#{DB_PATH}/main.db")

# Enable Write-Ahead Logging
DB.execute "PRAGMA journal_mode = WAL"

require 'config/schema'

Dir[File.join(APP_ROOT, 'model', '**', '*.rb')].each { |p| require p }
