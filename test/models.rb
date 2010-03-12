class Document
  include Griddle::HasGridAttachment
  
  has_grid_attachment :image, :styles => {
    :resized => "150x100!",
    :fitted => "150x150",
    :cropped_wide => '60x50#',
    :cropped_tall => '50x60#',
    :cropped_square => '50x50#'
  }
  
  def id
    object_id
  end
  
end