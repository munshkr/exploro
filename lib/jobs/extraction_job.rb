class ExtractionJob
  def self.perform(document_id)
    # TODO
    puts "Processing document #{document_id}..."
    sleep 3
    puts "Done"
  end
end
