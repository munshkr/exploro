class Project < Sequel::Model(DB[:projects])
  plugin :timestamps
  plugin :validation_helpers

  many_to_many :documents, join_table: :documents_projects

  def validate
    super
    validates_presence :name
  end
end
