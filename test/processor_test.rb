# require "test_helper"
# require "models"
# 
# class ProcessorTest < Test::Unit::TestCase
#   
#   context "A Processor" do
#     
#     setup do
#       @processor = Griddle::Processor.new
#     end
#     
#     should "be a type of processor" do
#       assert_kind_of Griddle::Processor, @processor
#     end
#     
#   end
#   
#   context "An Attachment" do
#     
#     setup do
#       @dir = File.dirname(__FILE__) + '/fixtures'
#       @image = File.open("#{@dir}/baboon.jpg", 'r')
#       @options = {
#         :processor => :ImageMagick
#       }
#       @doc = DocNoAttachment.create
#       
#     end
#     
#     context "without processor options" do
#       
#       setup do
#         @attachment = Griddle::Attachment.for(:image, @doc)
#       end
#       
#       should "have default to processor ImageMagick" do
#         assert_equal Griddle::Processor::ImageMagick, @attachment.processor.klass
#       end
#       
#     end
#     
#     context "and a file" do
#       
#       setup do
#         @attachment = Griddle::Attachment.for(:image, @doc, @options)
#       end
#       
#       should "have a processor of ImageMagick" do
#         assert_equal Griddle::Processor::ImageMagick, @attachment.processor.klass
#       end
#       
#     end
#     
#   end
#   
# end