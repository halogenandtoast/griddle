module Griddle
  class Processor
    
    attr_accessor :klass
    
    def initialize( input_file, processor_class = :ImageMagick )
      @input_file = input_file
      processor_class = :ImageMagick unless valid_processors.include? processor_class
      self.klass = self.class.const_get "#{processor_class}"
    end
    
    def file
      @input_file
    end
    
    def resize(*args)
      raise "Declare in #{self.klass.to_s}"
    end
    
    protected
    def valid_processors
      [:ImageMagick]
    end
    
  end
end