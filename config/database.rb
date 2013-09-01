require 'sequel'

DB_PATH = File.join(APP_ROOT, 'db')
DB = Sequel.connect("sqlite://#{DB_PATH}/main.db")

DB.create_table? :projects do
  primary_key :id
  String      :name, :null => false
  DateTime    :created_at, :null => false
  DateTime    :updated_at
end

DB.create_table? :documents do
  primary_key :id
  String      :filename, null: false
  Integer     :size, null: false
  String      :title
  DateTime    :created_at, null: false
  DateTime    :updated_at
  DateTime    :analyzed_at
  String      :state
  Integer     :percentage, null: false
end

DB.create_table? :documents_projects do
  primary_key :id
  foreign_key :document_id, :documents
  foreign_key :project_id, :projects
end

require 'model/project'
require 'model/document'
