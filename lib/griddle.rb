if RUBY_VERSION =~ /1.9.[0-9]/
  require 'fileutils'
else
  require 'ftools'
end
require 'mime/types'
require 'griddle/has_grid_attachment'
require 'griddle/attachment'
require 'griddle/upfile'

module Griddle
  def self.version
    "0.0.1"
  end
end

File.send(:include, Griddle::Upfile)