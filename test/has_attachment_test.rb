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
      
      should "exist" do
        assert @document.image.exists?
      end
 
    end
    
    context "when assigned nil" do
      
      setup do
        @document.image = nil
        @document.save!
      end
      
      should "not exist" do
        assert !@document.image.exists?
      end
      
    end
    
    context "when assigned blank" do
      
      setup do
        @document.image = ""
        @document.save!
      end
      
      should "not exist" do
        assert !@document.image.exists?
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
        
        should "have a styles" do
          assert_kind_of Hash, @document.image.styles
        end
        
        should "have a method for each style" do
          assert @document.image.respond_to? :cropped
        end
        
        should "be a kind of attachment" do
          assert_kind_of Griddle::Attachment, @document.image.cropped
        end
        
        should "style should have a grid_key for cropped" do
          assert_equal "#{@document.class.to_s.tableize}/#{@document.id}/image/cropped/#{@document.image.cropped.file_name}", @document.image.cropped.grid_key
        end
        
        should "style should have a file for cropped" do
          assert @document.image.cropped.exists?
          assert !@document.image.cropped.file.read.blank?
        end
        
        {
          :resized => "150 x 100",
          :fitted => "150 x 114",
          :cropped => '60 x 50'
        }.each do |style|
        
          should "have the correct dimensions for #{style[0]}" do
            temp = Tempfile.new "#{style[0]}.jpg"
            style_attachment = @document.image.send(style[0])
            file_path = File.dirname(temp.path) + '/' + style_attachment.file_name
            File.open(file_path, 'w') do |f|
              f.write style_attachment.file.read
            end
            cmd = %Q[identify -format "%[fx:w] x %[fx:h]" #{file_path}]
            assert_equal style[1], `#{cmd}`.chomp
          end
          
        end
        
      end
      
    end
    
    context "with a invalid style name" do
      
      setup do
        @document = DocWithInvalidStyles.new
      end
      
      should "raise an error indicating an invalid style name" do
        assert_raise RuntimeError do
          @document.image = @image
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