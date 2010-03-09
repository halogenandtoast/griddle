require 'mongo_mapper'

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
    :medium => "150x100!",
    :thumb => '50x50#'
  }
  
end

# invalid because one of the styles is a reserved word
class DocWithInvalidStyles
  include MongoMapper::Document
  include Griddle::HasGridAttachment
  
  has_grid_attachment :image, :styles => {
    :file => "50x50#",
    :thumb => '50x50#'
  }
  
end