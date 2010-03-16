Griddle: GridFileSystem made simple
=======================================

Griddle is a file attachment gem for use with `mongo-ruby-driver`.

Installation
------------------

Install the gem:

    gem install griddle


Usage
---------------------------------------

A class with a grid attachment:

    class Document
      
      include Griddle::HasGridAttachment
      
      has_grid_attachment :image, :styles=>{
        :thumb => "50x50#"
      }
      
    end

Or, alternately if you're using an object model

    class Document
      
      include MongoMapper::Document
      include Griddle::HasGridAttachment
      
      has_grid_attachment :image, :styles=>{
        :thumb => "50x50#"
      }
      
    end
      
Create a document:
    
    @document = Document.new
    @document.image = File.new("attached_file.jpg", 'rb')
    @document.save_attached_files
    
Or, if you're using an object model, `saved_attached_files` is called `after_save`:

    image = File.new("attached_file.jpg", 'rb')
    @document = Document.new(:image => image)
    @document.save
    
Retrieving A File
-----------------

The contents of a file stored in GridFileSystem can be retrieved using `Mongo::GridIO` accessed by the `file` method:

    @document.image.file
    => <#Mongo::GridIO>
    
    @document.image.file.read
    => contents of file

Some other methods that may be helpful to know:
  
    # does the attachment exist?
    @document.image.exist?
    => true
    
    # attachment file name
    @document.image.file_name
    => attached_file.jpg
    
    # attachment grid key
    @document.image.grid_key
    => document/12345/image/attached_file.jpg
    
Styles
------

Griddle makes use of `ImageMagik` processor to fit and/or crop images and store different image `styles`:

    @document.image.styles
    => {:thumb => '50x50#'}

Each style is saved as a `Griddle::Attachment` as well:

    @document.image.thumb.exist?
    => true
    
    @document.image.thumb.file_name
    => attached_file.jpg
    
    @document.image.thumb.grid_key
    => documents/12345/images/attached_file.jpg

Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2010 Matt Matt san Mongeau. See LICENSE for details.
