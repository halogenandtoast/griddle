module Griddle
  class Attachment

    def self.attachment_for(options)
      options.symbolize_keys!
      options_for_search = {:name => options[:name], :owner_type => options[:owner_type], :owner_id => options[:owner_id]}
      record = collection.find_one(options_for_search)
      return new(record) unless record.nil?
      return new(options)
    end

    def self.collection
      @collection ||= Griddle.database.collection('griddle.attachments')
    end
    
    def self.for(name, owner, options = {})
      attachment_for(options.merge({
        :name => name,
        :owner_type => owner.class.to_s,
        :owner_id => owner.id
      }))
    end

    def self.valid_attributes
      [:name, :owner_id, :owner_type, :file_name, :file_size, :content_type, :styles, :options]
    end
    #     belongs_to :owner, :polymorphic => true
    
    attr_accessor :attributes

    def initialize(attributes = {})
      @attributes = attributes.symbolize_keys
      initialize_processor
      initialize_styles
      create_attachments_for_styles
    end
    
    def assign(uploaded_file)
      if valid_assignment?(uploaded_file)
        self.file = uploaded_file
      end
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
    
    def grid_key
      @grid_key ||= "#{owner_type.tableize}/#{owner_id}/#{name}/#{self.file_name}".downcase
    end
    
    def file
      GridFS::GridStore.new(Griddle.database, grid_key, 'r') unless file_name.blank?
    end
    
    def file=(new_file)
      filename = new_file.respond_to?(:original_filename) ? new_file.original_filename : File.basename(new_file.path)
      self.file_name = filename
      self.file_size = File.size(new_file)
      self.content_type = new_file.content_type
      @tmp_file = new_file
    end
    
    def processor
      @processor
    end
    
    def processor= processor
      @attributes[:processor] = processor
      initialize_processor
    end

    def save
      save_file
      collection.insert(valid_attributes(@attributes).stringify_keys)
    end
    
    def styles
      @styles
    end
    
    def styles= styles
      @attributes[:styles] = styles
      initialize_styles
    end

    def valid_attributes(attributes)
      Hash[*attributes.select{|key, value| self.class.valid_attributes.include?(key) }.flatten]
    end
    
    private
    
    def create_attachments_for_styles
      self.styles.each do |h|
        create_style_attachment h[0]
      end
    end
    
    def create_style_attachment style_name
      raise "Invalid style name :#{style_name}. #{style_name} is a reserved word." if respond_to?(style_name) || !attributes[style_name.to_sym].nil?
      
      attrs = attributes.merge({
        :name => "#{name}/#{style_name}",
        :styles => {}
      })
      self.class_eval do
        
        define_method(style_name) do |*args|
          Attachment.attachment_for(attrs)
        end
      
        define_method("#{style_name}=") do |file|
          Attachment.for(attrs).assign(file)
        end
        
      end
    end
    
    def initialize_processor
      @processor = Processor.new @attributes[:processor]
    end
    
    def initialize_styles
      @styles = {} 
      if @attributes[:styles] && @attributes[:styles].is_a?(Hash)
        @styles = @attributes[:styles].inject({}) do |h, value|
          h[value.first.to_sym] = Style.new value.first, value.last, self
          h
        end
      end
    end
    
    def save_file
      unless @tmp_file.nil?
        GridFS::GridStore.open(Griddle.database, grid_key, 'w', :content_type => self.content_type) do |f|
          f.write @tmp_file.read
        end
        styles.each do |h|
          processed_file = processor.process_image(@tmp_file, h[1])
          style_attachment = send(h[0])
          style_attachment.assign(processed_file)
          style_attachment.save
        end
      end
    end
    
    def valid_assignment?(file)
      (file.respond_to?(:original_filename) && file.respond_to?(:content_type))
    end
    
  end
end