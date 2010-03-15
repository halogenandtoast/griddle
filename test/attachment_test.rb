require "test_helper"
require "models"

include Mongo

class AttachmentTest < Test::Unit::TestCase
  
  context "An Attachment" do
    
    setup do
      @dir = File.dirname(__FILE__) + '/fixtures'
      @image = File.open("#{@dir}/baboon.jpg", 'r')
      @doc = DocNoAttachment.create
      @attachment = Griddle::Attachment.for(:image, @doc)
    end
    
    should "have a #grid_key" do
      assert_equal @attachment.grid_key, "#{@doc.class.to_s.tableize}/#{@doc.id}/image/"
    end
    
    should "#assign a valid assignment" do
      @attachment.assign(@image)
      @attachment.save
      assert_kind_of Mongo::GridIO, @attachment.file 
      assert @attachment.exists?
    end
    
    context "with a file" do
      
      setup do
        @attachment.assign(@image)
      end
    
      should "#destroy_file" do
        @attachment.destroy_file
        assert !@attachment.exists?
      end
      
    end
    
  end
  
  
end