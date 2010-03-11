if RUBY_VERSION =~ /1.9.[0-9]/
  require 'fileutils'
else
  require 'ftools'
end
require 'rubygems'
require 'mime/types'
require 'tempfile'
require 'griddle/has_grid_attachment'
require 'griddle/attachment'
require 'griddle/upfile'
require 'griddle/style'
require 'griddle/processor/image_magick'
require 'griddle/processor'

module Griddle
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), "..", "VERSION")).chomp
  end
  
  def self.database
    @database ||= if(defined?(MongoMapper))
      MongoMapper.database
    else
      nil
    end
  end
  
  def self.database=(database)
    @database = database
  end
  
end

File.send(:include, Griddle::Upfile)

