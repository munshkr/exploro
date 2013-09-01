class Project < Sequel::Model
  plugin :timestamps
  plugin :schema

  set_schema do
    primary_key :id
    String      :name, :null => false
    DateTime    :created_at, :null => false
    DateTime    :updated_at
  end
end
