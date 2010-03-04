require "test_helper"
require "models"
 
class HasAttachmentTest < Test::Unit::TestCase
  context "A Doc that has_grid_attachment :image" do
    setup do
      @document = Doc.new
      @dir = File.dirname(__FILE__) + '/fixtures'
      @image = File.open("#{@dir}/baboon.jpg", 'r')
      @file_system = MongoMapper.database['fs.files']
    end
 
    teardown do
      #@file_system.drop
      @image.close
    end
 
    should "have :after_save callback" do
      assert_equal(1, Doc.after_save.collect(&:method).count)
    end
 
    context "when assigned a file" do
      setup do
        @document.image = @image
        @document.save!
      end
 
      should "should return an Attachment" do
        assert_equal(Griddle::Attachment, @document.image.class)
      end
 
      should "read file from grid store" do
        assert_equal "image/jpeg", @file_system.find_one(:filename => @document.image.grid_key)['contentType']
      end
 
    end
    
    context "with styles" do
      
      setup do
        @document = DocWithStyles.new
      end
      
      context "when assigned a file" do
        
        setup do
          @document.image = @image
          @document.save!
        end
        
        should "create a thumbnail version" do
          assert_equal "#{@document.class.to_s.tableize}/#{@document.id}/image/thumb/", @document.image.thumb.grid_key
        end
        
      end
      
    end
 
    context "when multiple instances" do
      setup do
        @document2 = Doc.new
        @image2 = File.open("#{@dir}/fox.jpg", 'r')
        @document3 = Doc.new
        @image3 = File.open("#{@dir}/baboon.jpg", 'r')
        @document2.image = @image2
        @document3.image = @image3
      end
    end
 
  end
 
end