class Page < Sequel::Model(DB[:pages])
  plugin :timestamps
  plugin :validation_helpers

  many_to_one :document, key: :document_id
  one_to_many :text_lines, key: :page_id
  #one_to_many :named_entities

  SEPARATOR = "\n"

  def text
    text_lines_dataset.order(:num).select_map(:text).join(TextLine::SEPARATOR)
  end
end
