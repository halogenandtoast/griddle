$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'mongo_mapper'
require 'griddle'
require 'test/unit'
require 'shoulda'

TEST_DB = 'griddle-test' unless Object.const_defined?("TEST_DB")
 
MongoMapper.database = TEST_DB
 
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