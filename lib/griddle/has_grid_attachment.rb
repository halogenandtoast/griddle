require 'mongo/gridfs'
module Griddle
  module HasGridAttachment
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end
    
    module ClassMethods
      def has_grid_attachment name, options = {}
        write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
        attachment_definitions[name] = options

        after_save :save_attached_files
        
        define_method(name) do |*args|
          attachment_for(name)
        end
        
        define_method("#{name}=") do |file|
          attachment_for(name).assign(file)
        end        
      end
      
      def attachment_definitions
        read_inheritable_attribute(:attachment_definitions)
      end
    end
    
    module InstanceMethods
      
      def attachment_for name
        @_gripster_attachments ||= {}
        @_gripster_attachments[name] ||= Attachment.for(name, self)
      end
      
      def each_attachment
        self.class.attachment_definitions.each do |name, definition|
          yield(name, attachment_for(name))
        end
      end
      
      def save_attached_files
        each_attachment do |name, attachment|
          attachment.owner_id = self.id
          attachment.send(:save) unless attachment.nil?
        end
      end
    end
  end
end
