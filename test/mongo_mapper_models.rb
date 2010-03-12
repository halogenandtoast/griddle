MongoMapper.database = Griddle.database.name

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
    :resized => "150x100!",
    :fitted => "150x150",
    :cropped_wide => '60x50#',
    :cropped_tall => '50x60#',
    :cropped_square => '50x50#'
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

class DocWithMultipleAttachments
  include MongoMapper::Document
  include Griddle::HasGridAttachment
  
  has_grid_attachment :image
  has_grid_attachment :pdf
  
end