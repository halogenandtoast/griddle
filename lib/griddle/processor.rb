module Griddle
  class Processor
    
    attr_accessor :klass
    
    def initialize( processor_class = :ImageMagick )
      processor_class = :ImageMagick unless valid_processors.include? processor_class
      self.klass = self.class.const_get "#{processor_class}"
    end
    
    protected
    def valid_processors
      [:ImageMagick]
    end
    
  end
end