class ExtractionJob
  def self.perform(id)
    # TODO
    puts "Processing document #{id}..."

    @document = Document[id]
    puts "Document original filename is '#{@document.filename}'"

    sleep 3
    puts "Done"
  end
end
