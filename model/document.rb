class Document < Sequel::Model(DB[:documents])
  plugin :timestamps
  plugin :validation_helpers
  plugin :json_serializer

  many_to_one :project, key: :project_id
  one_to_many :pages, key: :document_id

  BLOCK_SEPARATOR = ".\n"

  def self.create_from_file(path, values={}, &block)
    new_document = self.create(values.merge(
      filename: File.basename(path),
      size: File.size?(path)), &block)

    # Copy file to project's files dir
    FileUtils.mkdir_p(File.dirname(new_document.path))
    FileUtils.mv(path, new_document.path)

    new_document
  end

  def before_validation
    self.percentage ||= 0
  end

  def validate
    super
    validates_presence [:project, :filename, :size, :percentage]
    #validates_unique :filename
    validates_format /^\d+$/, :size if size
    validates_format /^\d+$/, :percentage if percentage
  end

  def process!
    if id
      require 'lib/document_job'
      DocumentJob.perform(id)
    end
  end

  def path
    File.join(project.path, 'files', filename.to_s) if project.path
  end

  def text
    pages_dataset.order(:num).map(&:text).join(TextLine::SEPARATOR)
  end

  def iterator
    require 'lib/document_iterator'
    DocumentIterator.new(self)
  end
end
