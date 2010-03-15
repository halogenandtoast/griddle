require "test_helper"
require "models"
include Mongo
 
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
      
      context "when assigned a new file" do
      
        setup do
          @new_file = File.new("#{@dir}/climenole.jpeg", 'rb')
          @document.image = @new_file
          @document.save!
          @document = Doc.find(@document.id)
        end
      
        should "be the new file" do
          assert_equal "climenole.jpeg", @document.image.file_name
          @new_file.rewind
          assert_equal @new_file.read.length, @document.image.file.read.length
        end
      
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
      
      context "when assigned an image" do
        
        setup do
          @document.image = @image
          @document.save!
        end
        
        should "have a styles" do
          assert_kind_of Hash, @document.image.styles
        end
        
        should "have a method for each style" do
          assert @document.image.respond_to? :cropped_wide
        end
        
        should "be a kind of attachment" do
          assert_kind_of Griddle::Attachment, @document.image.cropped_wide
        end
        
        should "style should have a grid_key for cropped" do
          assert_equal "doc_with_styles/#{@document.id}/image/cropped_wide/baboon.jpg", @document.image.cropped_wide.grid_key
        end
        
        should "style should have a file for cropped" do
          assert @document.image.cropped_wide.exists?
          assert !@document.image.cropped_wide.file.read.blank?
        end
        
        should "delete an image and its styles" do
          grid_keys = @document.image.styles.inject([]) do |a,style|
            a << @document.image.send(style[0]).grid_key
            a
          end
          
          grid_keys << @document.image.grid_key
          
          @document.image.destroy
          
          grid_keys.each do |grid_key|
            assert Griddle.database['fs.files'].find({'filename' => grid_key}).count == 0
          end
        end
        
      end
      
      image_varations = {
        "wider than taller" => {
          :file_name => "baboon.jpg",
          :expected_dimensions => {
            :resized => "150 x 100",
            :fitted => "150 x 114",
            :cropped_wide => '60 x 50',
            :cropped_tall => '50 x 60',
            :cropped_square => '50 x 50'
          }
        },
        "taller than wider" => {
          :file_name =>"climenole.jpeg",
          :expected_dimensions => {
            :resized => "150 x 100",
            :fitted => "94 x 150",
            :cropped_wide => '60 x 50',
            :cropped_tall => '50 x 60',
            :cropped_square => '50 x 50'
          }
        },
        "square" => {
          :file_name => "squid.png",
          :expected_dimensions => {
            :resized => "150 x 100",
            :fitted => "150 x 150",
            :cropped_wide => '60 x 50',
            :cropped_tall => '50 x 60',
            :cropped_square => '50 x 50'
          }
        },
      }
      
      image_varations.each do |variant|
        description, variant = variant
      
        context "when assigned an image that is #{description}" do
        
          setup do
            @document.image = File.new("#{@dir}/#{variant[:file_name]}", 'rb')
            @document.save!
          end
        
          variant[:expected_dimensions].each do |style|
            style_name, dimensions = style
        
            should "have the correct dimensions for #{style_name}" do
              temp = Tempfile.new "#{style[0]}.jpg"
              style_attachment = @document.image.send(style_name)
            
              file_path = File.dirname(temp.path) + '/' + style_attachment.file_name
              File.open(file_path, 'w') do |f|
                f.write style_attachment.file.read
              end
              cmd = %Q[identify -format "%[fx:w] x %[fx:h]" #{file_path}]
              assert_equal dimensions, `#{cmd}`.chomp
            end
          
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
    
  end
  
  context "A Document with multiple attachments" do
    
    setup do
      @document = DocWithMultipleAttachments.new
      @dir = File.dirname(__FILE__) + '/fixtures'
      @document.image = File.open("#{@dir}/baboon.jpg", 'r')
      @document.pdf = File.open("#{@dir}/sample.pdf", 'r')
      @document.save
      
      @grid_keys = [@document.image.grid_key, @document.pdf.grid_key]
    end
    
    should "destroy_attached_files" do
      @document.destroy_attached_files
      @grid_keys.each do |grid_key|
        assert Griddle.database['fs.files'].find({'filename' => grid_key}).count == 0
      end
    end
    
    should "destroy on after_destroy" do
      @document.destroy
      @grid_keys.each do |grid_key|
        assert Griddle.database['fs.files'].find({'filename' => grid_key}).count == 0
      end
    end
    
  end
  
  context "A Document with no object model" do
    
    setup do
      @document = Document.new
      @dir = File.dirname(__FILE__) + '/fixtures'
      @image = File.open("#{@dir}/baboon.jpg", 'r')
    end
    
    should "have a method for save_attached_files" do
      assert @document.respond_to? :save_attached_files
    end
    
    should "save_attached_files" do
      @document.save_attached_files
      attachment = Griddle::Attachment.for(:image, @document)
      attachment.attributes.delete(:_id)
      assert_equal @document.image.attributes, attachment.attributes
    end
    
  end
 
end