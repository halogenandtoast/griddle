if RUBY_VERSION =~ /1.9.[0-9]/
  require 'fileutils'
else
  require 'ftools'
end
require 'rubygems'
require 'mime/types'
require 'griddle/has_grid_attachment'
require 'griddle/attachment'
require 'griddle/upfile'
require 'griddle/style'

module Griddle
  def self.version
    "0.0.1"
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

