class TextLine < Sequel::Model(DB[:text_lines])
  many_to_one :page, key: :page_id

  SEPARATOR = "\n"
end
