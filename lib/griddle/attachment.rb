module Griddle
  class Attachment

    def self.attachment_for(name, owner_type, owner_id)
      options = {:name => name, :owner_type => owner_type, :owner_id => owner_id}
      record = collection.find_one(options)
      return new(record) unless record.nil?
      return new(options)
    end

    def self.collection
      @collection ||= Griddle.database.collection('griddle.attachments')
    end
    
    def self.for(name, owner, options = {})
      a = attachment_for(name, owner.class.to_s, owner.id)
      a.styles = options.dup.delete(:styles) || {}
      a
    end

    def self.valid_attributes
      [:name, :owner_id, :owner_type, :file_name, :file_size, :content_type, :styles, :options]
    end
    #     belongs_to :owner, :polymorphic => true
    
    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes.symbolize_keys
    end
    
    def assign(uploaded_file)
      return nil unless valid_assignment?(uploaded_file)
      @tmp_file = uploaded_file
    end
    
    def attributes
      @attributes
    end

    def attributes=(attributes)
      @attributes.merge!(attributes).symbolize_keys
    end

    def collection
      @collection ||= self.class.collection
    end
    
    def destroy
      destroy_file
      collection.remove({:name => name, :owner_type => owner_type, :owner_id => owner_id})
    end
    
    def method_missing(method, *args, &block)
      key = method.to_s.gsub(/\=$/, '').to_sym
      if self.class.valid_attributes.include?(key)
        if key != method
          @attributes[key] = args[0]
        else
          @attributes[key]
        end
      elsif @attributes[:styles].has_key?(method)
        @styles[method].attachment_for
      else
        super
      end
    end
    
    def destroy_file
      GridFS::GridStore.unlink(Griddle.database, grid_key)
    end
    
    def exists?
      !file_name.nil?
    end
    
    def generate_system_file
      temp_file = grid_key + file_name
      
      unless File.exists? temp_file
        FileUtils.mkdir_p(grid_key)
        File.open(temp_file,'w') do |f|
         f.write file.read
        end
      end
      
      File.new(temp_file, 'rb')
    end
    
    def grid_key
      @grid_key ||= "#{owner_type.tableize}/#{owner_id}/#{name}/#{file_name}".downcase
    end
    
    def file
      GridFS::GridStore.new(Griddle.database, grid_key, 'r') unless file_name.blank?
    end
    
    def file=(new_file)
      file_name = new_file.respond_to?(:original_filename) ? new_file.original_filename : File.basename(new_file.path)
      self.file_name = file_name
      self.file_size = File.size(new_file)
      self.content_type = new_file.content_type
      
      GridFS::GridStore.open(Griddle.database, grid_key, 'w', :content_type => self.content_type) do |f|
        f.write new_file.read
      end
    end

    def save
      save_file
      collection.insert(valid_attributes(@attributes).stringify_keys)
    end
    
    def styles
      @styles ||= initialize_styles
    end
    
    def styles= styles
      @attributes[:styles] = styles
      @styles = initialize_styles
    end

    def valid_attributes(attributes)
      Hash[*attributes.select{|key, value| self.class.valid_attributes.include?(key) }.flatten]
    end
    
    private
    
    def processor
      @processor ||= initialize_processor
    end
    
    def processor= processor
      @attributes[:processor] = processor
      @processor = initialize_processor
    end
    
    def initialize_processor
      Processor.new generate_system_file, @attributes[:processor]
    end
    
    def initialize_styles
      return {} unless @attributes[:styles] && @attributes[:styles].is_a?(Hash)
      @attributes[:styles].inject({}) do |h, value|
        h[value.first.to_sym] = Style.new value.first, value.last, self
        h
      end
    end
    
    def save_file
      self.file = @tmp_file if @tmp_file
    end
    
    def valid_assignment?(file)
      file.nil? || (file.respond_to?(:original_filename) && file.respond_to?(:content_type))
    end
    
  end
end