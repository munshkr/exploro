class Document < Sequel::Model(DB[:documents])
  plugin :timestamps
  plugin :validation_helpers

  many_to_many :projects, join_table: :documents_projects
  one_to_many  :pages, key: :document_id

  BLOCK_SEPARATOR = ".\n"

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

  def path
    File.join(FILES_PATH, filename)
  end

  def text
    pages_dataset.order(:num).map(&:text).join(TextLine::SEPARATOR)
  end

  def iterator
    require 'lib/document_iterator'
    DocumentIterator.new(self)
  end
end
