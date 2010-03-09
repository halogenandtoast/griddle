$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
gem 'activesupport', '2.3.5'
require 'mongo_mapper'
require 'griddle'
require 'test/unit'
require 'shoulda'
require 'tempfile'

TEST_DB = 'griddle-test' unless Object.const_defined?("TEST_DB")
 
MongoMapper.database = TEST_DB
 
#Griddle.database = Mongo::Connection.new.db(TEST_DB)
 
class Test::Unit::TestCase
  def teardown
    MongoMapper.database.collections.each do |coll|
      coll.remove
    end
  end
 
  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method teardown do
      super
    end
  end
end