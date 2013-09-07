class Project < Sequel::Model(DB[:projects])
  plugin :timestamps
  plugin :validation_helpers
  plugin :json_serializer

  one_to_many :documents, key: :project_id

  def validate
    super
    validates_presence :name
    validates_unique   :name
  end

  def path
    File.join(DB_PATH, id.to_s) if not new?
  end
end
