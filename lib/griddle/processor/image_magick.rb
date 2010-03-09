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
          fit(geometry_for_smaller_dimension)
          crop
        else
          fit
        end
        `mkdir -p ~/Desktop/griddle_resized`
        `cp #{@destination_file.path} ~/Desktop/griddle_resized/#{style.geometry.gsub(/#/,'_cropped')}_#{File.basename(@file.path)}`
        @destination_file
      end
      
      def width
        dimensions.first
      end
      
      private
      
      def geometry_for_smaller_dimension
        geometry =~ /#{smaller_dimension}x/ ? "#{smaller_dimension}x" : "x#{smaller_dimension}"
      end
      
      def smaller_dimension
        dimensions.sort.first
      end
      
      def dimensions
        @dimensions ||= geometry.scan(/([0-9]*)x([0-9]*)/).flatten.collect{|v|v.to_i}
      end
      
    end
  end
end