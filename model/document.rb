class Document < Sequel::Model
  plugin :timestamps
  plugin :schema
  plugin :validation_helpers

  set_schema do
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

  def before_validation
    self.percentage ||= 0
  end

  def validate
    super
    validates_presence [:filename, :size]
    validates_unique :filename
    validates_format /^\d+$/, [:size, :percentage]
  end

  def process!
    if id
      require 'qu'
      require 'lib/jobs/extraction_job'

      Qu.enqueue(ExtractionJob, id)
    end
  end
end
