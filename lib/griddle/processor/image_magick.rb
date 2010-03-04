module Griddle
  class Processor
    class ImageMagick < Processor
      
      def resize(geometry)
        cmd = "convert #{file.path} "
        cmd << "-resize #{geometry} " unless geometry.blank?
        cmd << "#{file.path} "
      
        `#{cmd}`
      end
      
    end
  end
end