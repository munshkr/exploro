class EntitiesRecognitionJob < DocumentJob
  #
  # Perform a morphological analysis and extract named entities like persons,
  # organizations, places, dates and addresses.
  #
  # When finished, enqueue the coreference resolution task. Also, if any
  # addresses were found, enqueue the geocoding task.
  #
  def self.perform(id)
    doc = Document[id]
    raise "Document with id #{id} not found" if doc.nil?

    doc.update(state: :entities_recognition)

    require 'csv'
    csv_path = File.join(doc.project.path, 'entities', "#{doc.id}.csv")
    FileUtils.mkdir_p(File.dirname(csv_path))
    CSV.open(csv_path, 'wb') do |csv|
      first_row = true

      logger.info "Extract named entities from content"
      #doc.named_entities_dataset.destroy
      doc_iter = doc.iterator

      require 'lib/analyzer'
      Analyzer.extract_named_entities(doc.processed_text).each do |ne_attrs, cur_pos, total_size|
        inner_pos = {}

        doc_iter.seek(ne_attrs[:pos])
        inner_pos["from"] = {
          "pid" => doc_iter.page.id,
          "tlid" => doc_iter.text_line.id,
          "pos" => doc_iter.inner_pos,
        }

        last_token = (ne_attrs[:tokens] && ne_attrs[:tokens].last) || ne_attrs
        doc_iter.seek(last_token[:pos] + last_token[:form].size - 1)
        inner_pos["to"] = {
          "pid" => doc_iter.page.id,
          "tlid" => doc_iter.text_line.id,
          "pos" => doc_iter.inner_pos,
        }

        ne_attrs[:inner_pos] = inner_pos

        if first_row
          csv << ne_attrs.keys
          first_row = false
        end
        csv << ne_attrs.merge(
          "tokens" => ne_attrs["tokens"].to_json,
          "inner_pos" => ne_attrs["inner_pos"].to_json
        ).values

        if total_size && total_size > 0
          doc.update(percentage: current_percentage(cur_pos, total_size))
          #logger.info "Status #{doc.percentage} %"
        end

        #ne_klass = case ne_attrs[:ne_class]
        #  when :addresses then AddressEntity
        #  when :actions then ActionEntity
        #  else NamedEntity
        #end
        #
        #ne = ne_klass.new(ne_attrs)
        #ne.save!

        #doc.named_entities << ne
        #doc.pages.in(:_id => ["from", "to"].map{ |k| ne.inner_pos[k]["pid"] }.uniq).each do |page|
        #  page.named_entities << ne
        #end
      end

    end # CSV.open

    #logger.info "Re-index project's Xapian DB"
    #project.reindex

    #logger.info "Count classes of named entities found"
    #doc.information = {
    #  :people => doc.people.count,
    #  :people_ne => doc.people_found.size,
    #  :dates_ne => doc.dates_found.size,
    #  :organizations_ne => doc.organizations_found.size
    #}

    logger.info "Save document"
    doc.update(percentage: current_percentage(100, 100))

    #logger.info "Enqueue Coreference Resolution task"
    #Resque.enqueue(CoreferenceResolutionTask, document_id)

    #if doc.addresses_found.count > 0
    #  logger.info "Enqueue Geocoding task (#{doc.addresses_found.count} addresses found)"
    #  Resque.enqueue(GeocodingTask, document_id)
    #end

    next_job!(id)
  end
end
