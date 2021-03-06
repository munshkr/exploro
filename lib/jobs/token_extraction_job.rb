class TokenExtractionJob < DocumentJob
  def self.perform(id)
    doc = Document[id]
    raise "Document with id #{id} not found" if doc.nil?

    doc.update(state: :token_extraction, percentage: current_percentage(0, 100))
    logger.info "Status #{doc.percentage} %"

    csv_path = File.join(doc.project.path, 'tokens', "#{doc.id}.csv")
    FileUtils.mkdir_p(File.dirname(csv_path))

    require 'csv'
    logger.info "Extract tokens and generate CSV"
    CSV.open(csv_path, 'wb') do |csv|
      first_row = true
      total_size = doc.processed_text.size

      require 'lib/analyzer'
      Analyzer.extract_tokens(doc.processed_text).each do |token|
        if first_row
          csv << token.keys
          first_row = false
        else
          csv << token.values
        end

        cur_perc = current_percentage(token[:pos], total_size)
        if cur_perc != doc.percentage
          doc.update(percentage: cur_perc)
        end
      end
    end

    logger.info "Generate aggregated CSV for Wordcloud"
    words = Hash.new(0)
    CSV.foreach(csv_path, headers: true) do |row|
      w = row['form'].downcase
      words[w] += 1
    end

    csv_path = File.join(doc.project.path, 'tokens', "#{doc.id}_wordcloud.csv")
    CSV.open(csv_path, 'wb') do |csv|
      csv << ['text', 'count']
      words.each do |word, count|
        csv << [word, count]
      end
    end

    logger.info "Save document"
    doc.update(state: :waiting, percentage: current_percentage(100, 100))
    logger.info "Status #{doc.percentage} %"

    next_job!(id)
  end
end
