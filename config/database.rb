require 'sequel'

DB_PATH = File.join(APP_ROOT, 'db')
DB = Sequel.connect("sqlite://#{DB_PATH}/main.db")

require 'model/project'
require 'model/document'

Project.create_table?
Document.create_table?
