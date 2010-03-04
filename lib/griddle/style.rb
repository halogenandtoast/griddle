module Griddle
  class Style
    
    attr_accessor :name, :definition, :attachment
    
    def initialize(name, definition, attachment)
      @name = name
      @attachment = attachment
      @definition = case 
      when definition.is_a?(String)
        {
          :geometry => definition
        }
      when definition.is_a?(Array)
        raise "Don't send an array to Style"
      else
        raise "Definition must be a type of String, Array, or Hash" unless definition.is_a?(Hash)
        {
          :geometry => definition[:geometry]
        }
      end
      
    end
    
    def [](key)
      return nil unless respond_to? key
      send(key)
    end
    
    def attachment
      @attachment
    end
    
    def attachment_for
      return @attachment_for_style unless @attachment_for_style.nil?
      @attachment_for_style = Attachment.attachment_for("#{attachment.name}/#{name}",attachment.owner_type,attachment.owner_id)
      
      
      # temp_file = @attachment_for_style.grid_key + attachment.file_name
      # 
      # FileUtils.mkdir_p(@attachment_for_style.grid_key)
      # File.open(temp_file,'w') do |f|
      #   f.write attachment.file.read
      # end
      # file = File.new(temp_file, 'rb')
      # 
      # scale = geometry.gsub(/#/,'')
      # cmd = "convert #{file.path} "
      # cmd << "-resize #{scale} " unless scale.blank?
      # cmd << "#{file.path} "
      # 
      # puts cmd
      # 
      # `#{cmd}`
      
      file = @attachment_for_style.processor.resize(geometry)
      
      @attachment_for_style.assign(file)
      @attachment_for_style.save
      FileUtils.rm_r(@attachment_for_style.grid_key.split('/').first)
      @attachment_for_style
    end
    
    def geometry
      @definition[:geometry]
    end
    
  end
end