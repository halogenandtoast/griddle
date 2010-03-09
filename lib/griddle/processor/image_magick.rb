module Griddle
  class Processor
    class ImageMagick
      
      def process_image name, file, style
        tmp = Tempfile.new name
        `convert -resize #{style.geometry.gsub(/#/,'')} #{file.path} #{tmp.path}`
        tmp
      end
      
    end
  end
end