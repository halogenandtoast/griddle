require "test_helper"
require "models"

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
      assert  @attachment.file.is_a? GridFS::GridStore
      assert GridFS::GridStore.exist?(DocNoAttachment.database, @attachment.grid_key)
    end
    
    context "with a file" do
      
      setup do
        @attachment.assign(@image)
      end
    
      should "#destroy_file" do
        @attachment.destroy_file
        assert !GridFS::GridStore.exist?(DocNoAttachment.database, @attachment.grid_key)
      end
      
    end
    
  end
  
  
end