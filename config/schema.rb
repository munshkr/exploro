# Create all global tables

DB.create_table? :projects do
  primary_key :id
  String      :name, :null => false
  DateTime    :created_at, :null => false
  DateTime    :updated_at
end

DB.create_table? :documents do
  primary_key :id
  foreign_key :project_id, :projects, on_delete: :cascade
  String      :filename, null: false
  Integer     :size, null: false
  String      :title
  DateTime    :created_at, null: false
  DateTime    :updated_at
  DateTime    :analyzed_at
  String      :state
  Integer     :percentage, null: false
  Text        :processed_text
end

DB.create_table? :pages do
  primary_key :id
  foreign_key :document_id, :documents, on_delete: :cascade
  Integer     :num
  Integer     :from_pos
  Integer     :to_pos
  Integer     :width
  Integer     :height
end

DB.create_table? :text_lines do
  primary_key :id
  foreign_key :page_id, :pages, on_delete: :cascade
  Integer     :num
  Text        :text, null: false
  Integer     :left
  Integer     :top
  Integer     :width

  # Text and location attributes of the processed text
  Text    :processed_text, null: false
  Integer :from_pos
  Integer :to_pos
end
