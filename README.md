# S3DirectUpload

Easily generate a form that allows you to upload directly to Amazon S3.
Multi file uploading supported by jquery-fileupload. 

Code extracted from Ryan Bates' [gallery-jquery-fileupload](https://github.com/railscasts/383-uploading-to-amazon-s3/tree/master/gallery-jquery-fileupload).

## Installation

Add this line to your application's Gemfile:

    gem 's3_direct_upload'

Then add a new initalizer with your AWS credentials:

**config/initalizers/s3_direct_upload.rb**
```ruby
S3DirectUpload.config do |c|
  c.access_key_id = ""       # your access key id
  c.secret_access_key = ""   # your secret access key
  c.bucket = ""              # your bucket name
end
```

Make sure your AWS S3 CORS settings for your bucket look something like this:
```
<CORSConfiguration>
    <CORSRule>
        <AllowedOrigin>http://0.0.0.0:3000</AllowedOrigin>
        <AllowedMethod>GET</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <AllowedMethod>PUT</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```
In production the AllowedOrigin key should be your domain.

Add the following js and css to your asset pipeline:

**application.js**
```ruby
//= require s3_direct_upload
```

**application.css**
```ruby
//= require s3_direct_upload_progress_bars
```

## Usage

Create a new view that uses the helper:
```ruby
<%= s3_uploader_form post: model_url, as: "model[image_url]" do %>
  <%= file_field_tag :file, multiple: true %>
<% end %>
```

Also place this template in the same view for the progress bars:
```javascript
<script id="template-upload" type="text/x-tmpl">
<div class="upload">
  {%=o.name%}
  <div class="progress"><div class="bar" style="width: 0%"></div></div>
</div>
</script>
```

### Customizations
Feel free to override the styling for the progress bars in s3_direct_upload_progress_bars, look at the source for inspiration.

Also feel free to write your own js to interface with jquery-file-upload. You might want to do this to do custom validations on the files before it is sent to S3 for example.
To do this remove `s3_direct_upload` from your application.js and include the necissary jquery-file-upload scripts (they are included in this gem automatically):
```javascript
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
```
and use the `s3_direct_upload` script as a guide, the form helper will still work fine if thats all you need.

### s3_uploader_form options and after upload callback
After the upload is complete, the script will execute an ajax POST to the model_url given in the `post` option in the form helper. 
The url to the file on S3 will be passed as a key to whatever is in the `as` option.

You could have your create action render a javascript file like this:

**create.js.erb**
```ruby
<% if @model.new_record? %>
  alert("Failed to upload model: <%= j @model.errors.full_messages.join(', ').html_safe %>");
<% else %>
  $("#paintings").append("<%= j render(@model) %>");
<% end %>
```
So that javascript code would be executed after the model instance is created, which would render your _model.html.erb template without a page reload if you wish.

It is recommended that you persist the image_url as an attribute on the model. To do this To do this add `resources model` in the routes file, and add the 'image_url' attribute to your model (can be whatever you set it as in the as options)


## Gotchas

Right now you can only have one upload form on a page.
Upload form is hardcoded with id '#fileupload'


## Contributing / TODO

This is just a simple gem that only really provides some javascript and a form helper. 
This gem could go all sorts of ways based on what people want and how people contribute. 
Ideas:
More specs! 
More options to control expiration, max filesize, file types etc.
Create generators.
Model methods.

## Credit

This gem is basically a small wrapper around code that [Ryan Bates](http://github.com/rbates) wrote for [Railscast#383](http://railscasts.com/episodes/383-uploading-to-amazon-s3). Most of the code in this gem was extracted from [gallery-jquery-fileupload](https://github.com/railscasts/383-uploading-to-amazon-s3/tree/master/gallery-jquery-fileupload). 

Thank you Ryan Bates!

This code also uses the excellecnt [jQuery-File-Upload](https://github.com/blueimp/jQuery-File-Upload), which is included in this gem by its rails counterpart [jquery-fileupload-rails](https://github.com/tors/jquery-fileupload-rails)
