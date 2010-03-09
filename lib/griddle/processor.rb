module Griddle
  class Processor
    
    attr_accessor :klass
    
    def initialize( processor_class = :ImageMagick )
      processor_class = :ImageMagick unless valid_processors.include? processor_class
      self.klass = self.class.const_get "#{processor_class}"
    end
    
    def process_image file, style
      processor = self.klass.new
      raise "Define in subclass" unless processor.respond_to? :process_image
      processor.process_image(file, style)
    end
    
    protected
    def valid_processors
      [:ImageMagick]
    end
    
  end
end