class Project < Sequel::Model(DB[:projects])
  plugin :timestamps
  plugin :validation_helpers
  plugin :json_serializer

  many_to_many :documents, join_table: :documents_projects, left_key: :project_id, right_key: :document_id

  def validate
    super
    validates_presence :name
    validates_unique   :name
  end
end
