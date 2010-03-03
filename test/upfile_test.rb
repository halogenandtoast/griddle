require "test_helper"

class UpfileTest < Test::Unit::TestCase
  
  context "A File" do
    setup do
      @dir = File.dirname(__FILE__) + '/fixtures'
      @image = File.open("#{@dir}/baboon.jpg", 'r')
    end
    
    should "have a #content_type" do
      assert_equal @image.content_type, "image/jpeg"
    end
    
    should "have an #original_filename" do
      assert_equal @image.original_filename, "baboon.jpg"
    end
    
    should "have a #size" do
      assert_equal @image.size, File.size(@image.path)
    end
    
  end
  
end