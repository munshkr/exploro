class Document < Sequel::Model(DB[:documents])
  plugin :timestamps
  plugin :validation_helpers

  many_to_many :projects, join_table: :documents_projects

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
