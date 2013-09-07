class ExtractionJob < DocumentJob
  PDFTOHTML_PATHS = %w{ /usr/local/bin/pdftohtml /usr/bin/pdftohtml }

  def self.perform(id)
    require 'docsplit'
    require 'nokogiri'

    doc = Document[id]
    raise "Document with id #{id} not found" if doc.nil?

    doc.update(state: :extraction, percentage: current_percentage(0, 100))
    logger.info "Status #{doc.percentage} %"

    logger.info "Ensure document is a PDF (convert if necessary)"
    pdf_path = Docsplit.ensure_pdfs(doc.path).first

    raise "Something failed when converting document to a PDF file" if pdf_path.nil?

    # Save original title from document
    logger.info "Extract title from '#{pdf_path}'"
    doc.update(title: Docsplit.extract_title(pdf_path))

    logger.info "Extract PDF as an XML document"
    xml = pdf_to_xml(pdf_path)

    logger.info "Clean old pages (if any)"
    doc.pages_dataset.destroy

    logger.info "Iterate through every page and text line, normalize and store them"
    total_pages = xml.css("page").count
    xml.css("page").each_with_index do |xml_page, page_index|
      logger.info "Page #{page_index + 1}"

      DB.transaction do
        logger.debug "Create page #{page_index + 1} and store text lines and attributes"
        page = doc.add_page({
          num: page_index + 1,
          width:  xml_page.attributes["width"].value.to_i,
          height: xml_page.attributes["height"].value.to_i,
        })

        logger.debug "Create and normalize text lines for page #{page_index + 1}"
        xml_page.css("text").each_with_index do |tl, tl_index|
          page.add_text_line({
            num: tl_index + 1,
            text: tl.inner_html,
            processed_text: normalize(tl.inner_html),
            left: tl.attributes["left"].value.to_i,
            top: tl.attributes["top"].value.to_i,
            width: tl.attributes["width"].value.to_i,
          })
        end
        logger.debug "#{page.text_lines_dataset.count} text lines were processed"

        doc.update(percentage: current_percentage(page_index + 1, total_pages))
        logger.info "Status #{doc.percentage} %"
      end
    end
    logger.info "#{doc.pages_dataset.count} pages were processed"

    logger.info "Save document"
    doc.update(state: :waiting, percentage: current_percentage(100, 100))
    logger.info "Status #{doc.percentage} %"

    next_job!(id)
  end

private
  # Normalize string for analyzer
  #   * Strip whitespace
  #   * Remove HTML tags (like <b></b>)
  #
  def self.normalize(string)
    string
      .strip
      .gsub(/<\/?[^>]*>/, '')
  end

  # Extracts XML from a PDF using Poppler's `pdftohtml`
  #
  def self.pdf_to_xml(path, opts={})
    params = ["-stdout", "-xml", "-enc UTF-8", "-wbt 20"]
    params << "-f #{opts[:from]}" if opts[:from]
    params << "-l #{opts[:to]}" if opts[:to]
    logger.debug "pdftohtml options: #{params}"

    command = "#{pdftohtml_bin} #{params.join(" ")} '#{path.gsub("'", "\\'")}'"
    logger.debug "Run #{command}"
    content = `#{command}`

    logger.debug "Parse XML output"
    require "nokogiri"
    xml = Nokogiri::XML(content)
  end

  def self.pdftohtml_bin
    return @pdftohtml_bin if @pdftohtml_bin

    if ENV["PDFTOHTML_BIN"]
      if File.exists?(ENV["PDFTOHTML_BIN"])
        @pdftohtml_bin = ENV["PDFTOHTML_BIN"]
      else
        raise "pdftohtml is not installed on #{ENV["PDFTOHTML_BIN"]}"
      end
    else
      PDFTOHTML_PATHS.each do |path|
        if File.exists?(path)
          @pdftohtml_bin = path
          return @pdftohtml_bin
        end
      end
      raise "pdftohtml is not installed"
    end
  end
end
