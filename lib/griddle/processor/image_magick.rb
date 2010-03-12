module Griddle
  class Processor
    class ImageMagick
      
      def crop
        `convert #{File.expand_path(@destination_file.path)} -crop #{geometry} -gravity Center #{@destination_file.path}`
      end
      
      def crop?
        @style.geometry =~ /#/
      end
      
      def file_width
        file_dimensions.first
      end
      
      def fit(geo = geometry)
        `convert #{File.expand_path(@file.path)} -resize #{geo} #{@destination_file.path}`
      end
      
      def geometry
        @geometry ||= @style.geometry.gsub(/#/,'')
      end
      
      def file_height
        file_dimensions.last
      end
      
      def height
        dimensions.last
      end
      
      def process_image file, style
        @style = style
        @file = file
        @destination_file = Tempfile.new @file.original_filename
        if crop?
          fit(resize_geometry_for_crop)
          crop
        else
          fit
        end
        @destination_file
      end
      
      def width
        dimensions.first
      end
      
      private
      
      def dimensions
        @dimensions ||= dimensions_for(geometry)
      end
      
      def dimensions_for geo
        geo.scan(/([0-9]*)x([0-9]*)/).flatten.collect{|v|v.to_f}
      end
      
      def file_dimensions
        @file_dimensions ||= dimensions_for(`identify -format "%[fx:w]x%[fx:h]" #{File.expand_path(@file.path)}`)
      end
      
      def resize_for_width?
        file_height*(width/file_width) >= height
      end
      
      def resize_geometry_for_crop
        resize_for_width? ? "#{width}x" : "x#{height}"
      end
      
    end
  end
end