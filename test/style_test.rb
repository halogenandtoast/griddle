require "test_helper"
require "models"

class StyleTest < Test::Unit::TestCase
  
  context "An Attachment with style rules" do
    
    setup do
      @dir = File.dirname(__FILE__) + '/fixtures'
      @image = File.open("#{@dir}/baboon.jpg", 'r')
      @options = {
        :styles=>{
          :thumb => "50x50#"
        }
      }
      
      @doc = DocNoAttachment.create
      @attachment = Griddle::Attachment.new(:image, @doc, @options)
    end
    
    context "and a file" do
      
      setup do
        @attachment.assign(@image)
      end
      
      should "have a styles hash" do
        assert_kind_of Hash, @attachment.styles
      end
      
      should ":thumb be a type of Griddle::Style" do
        assert_kind_of Griddle::Style, @attachment.styles[:thumb]
      end
      
      should "have a geometry for a style" do
        assert_equal @options[:styles][:thumb], @attachment.styles[:thumb][:geometry]
      end
      
      should "have a #geometry for a style" do
        assert_equal @options[:styles][:thumb], @attachment.styles[:thumb].geometry
      end
      
    end
    
  end
  
end