module Griddle
  class Processor
    class ImageMagick
      
      def crop
        `convert #{File.expand_path(@destination_file.path)} -crop #{geometry} -gravity Center #{@destination_file.path}`
      end
      
      def crop?
        @style.geometry =~ /#/
      end
      
      def fit(geo = geometry)
        `convert #{File.expand_path(@file.path)} -resize #{geo} #{@destination_file.path}`
      end
      
      def geometry
        @geometry ||= @style.geometry.gsub(/#/,'')
      end
      
      def height
        dimensions.last
      end
      
      def process_image file, style
        @style = style
        @file = file
        @destination_file = Tempfile.new File.basename(@file.path)
        if crop?
          fit(resize_geometry_for_crop)
          crop unless square_image?
        else
          fit
        end
        # `mkdir -p ~/Desktop/griddle_resized`
        # `cp #{@destination_file.path} ~/Desktop/griddle_resized/#{style.geometry.gsub(/#/,'_cropped')}_#{File.basename(@file.path)}`
        @destination_file
      end
      
      def width
        dimensions.first
      end
      
      private
      
      def file_dimensions
        @file_dimensions ||= dimensions_for(`identify -format "%[fx:w]x%[fx:h]" #{File.expand_path(@file.path)}`)
      end
      
      def dimensions
        @dimensions ||= dimensions_for(geometry)
      end
      
      def dimensions_for geo
        geo.scan(/([0-9]*)x([0-9]*)/).flatten.collect{|v|v.to_i}
      end
      
      def resize_geometry_for_crop
        if width==height
          file_dimensions.first > file_dimensions.last ? "x#{height}" : "#{width}x"
        else
          geometry =~ /#{smaller_dimension}x/ ? "#{smaller_dimension}x" : "x#{smaller_dimension}"
        end
      end
      
      def smaller_dimension
        dimensions.sort.first
      end
      
      def square_image?
        file_dimensions.first == file_dimensions.last
      end
      
    end
  end
end