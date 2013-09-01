class Document < Sequel::Model
  plugin :timestamps
  plugin :schema

  set_schema do
    primary_key :id
    String      :filename, :null => false
    String      :size, :null => false
    String      :title
    DateTime    :created_at, :null => false
    DateTime    :updated_at
    DateTime    :analyzed_at
    String      :state
    Integer     :percentage
  end

  def process!
    if id
      require 'qu'
      require 'lib/jobs/extraction_job'

      Qu.enqueue(ExtractionJob, id)
    end
  end
end
