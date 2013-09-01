class Project < Sequel::Model
  plugin :timestamps
  plugin :schema
  plugin :validation_helpers

  set_schema do
    primary_key :id
    String      :name, :null => false
    DateTime    :created_at, :null => false
    DateTime    :updated_at
  end

  def validate
    super
    validates_presence :name
  end
end
