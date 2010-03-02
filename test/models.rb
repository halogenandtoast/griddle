class Doc
  include MongoMapper::Document
  include Griddle::HasGridAttachment
  has_grid_attachment :image
end

class DocNoAttachment
  include MongoMapper::Document
end

class DocWithStyles
  include MongoMapper::Document
  include Griddle::HasGridAttachment
  
  has_grid_attachment :image, :styles => {
    :thumb => '50x50#'
  }
  
end