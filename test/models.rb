class Doc
  include MongoMapper::Document
  include Griddle::HasGridAttachment
  has_grid_attachment :image
end