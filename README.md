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
Create a new view that uses the form helper `s3_uploader_form`:
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

## Options for form helper
`post:` -> url in which is POST'd to after file is uploaded to S3. Example: model_url

`as:` -> parameter value for the POST in which the key will be the URL of the file on S3. If for example this is set to "model[image_url]" then the data posted would be `model[image_url] : http://bucketname.s3.amazonws.com/filename.ext`

`key:` -> key on s3. defaults to `"uploads/#{SecureRandom.hex}/${filename}"`. needs to be at least `"${filename}"`.

`acl:` -> acl for files uploaded to s3, defaults to "public-read"

`max_file_size:` -> maximum file size, defaults to 500.megabytes

`id:` -> optional html id for the form.

'class:' -> optional html class for the form.


### Persisting the S3 url
It is recommended that you persist the image_url that is sent back from the POST request (to the url given to the `post` option and as the key given in the `as` option). So to access your files later.

One way to do this is to make sure you have `resources model` in your routes file, and add the `image_url` (or whatever you would like to name it) attribute to your model, and then make sure you have the create action in your controller for that model.

You could then have your create action render a javascript file like this:
**create.js.erb**
```ruby
<% if @model.new_record? %>
  alert("Failed to upload model: <%= j @model.errors.full_messages.join(', ').html_safe %>");
<% else %>
  $("#container").append("<%= j render(@model) %>");
<% end %>
```
So that javascript code would be executed after the model instance is created, without a page refresh. See [@rbates's gallery-jquery-fileupload](https://github.com/railscasts/383-uploading-to-amazon-s3/tree/master/gallery-jquery-fileupload)) for an example of that method.

### Advanced Customizations
Feel free to override the styling for the progress bars in s3_direct_upload_progress_bars.css, look at the source for inspiration.

Also feel free to write your own js to interface with jquery-file-upload. You might want to do this to do custom validations on the files before it is sent to S3 for example.
To do this remove `s3_direct_upload` from your application.js and include the necessary jquery-file-upload scripts in your asset pipeline (they are included in this gem automatically):
```javascript
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
```
Use the javascript in `s3_direct_upload` as a guide.


There are now also a few javascript options for customization directly built into s3_direct_upload:

#### S3 Path

You can dynamically set the s3 file path:

`S3Uploader.path = 'path/to/my/files/on/s3'`

The file path in your s3 bucket will effectively be `S3Uploader.path + key`.

#### Before Add File callback

If you like to validate the filenames of files to be uploaded, you can hook into the uploader by setting the `S3Uploader.before_add` callback.
In your callback you can then either return true (upload file) or false (cancel upload).

#### Extra Data

You can send additional data to your rails app in the persistence post request by setting `S3Uploader.extra_data` 


## Contributing / TODO

This is just a simple gem that only really provides some javascript and a form helper. 
This gem could go all sorts of ways based on what people want and how people contribute. 
Ideas:
* More specs! 
* More options to control file types, ability to batch upload.
* More convention over configuration on rails side
* Create generators.
* Model methods.
* Model method to delete files from s3


## Credit

This gem is basically a small wrapper around code that [Ryan Bates](http://github.com/rbates) wrote for [Railscast#383](http://railscasts.com/episodes/383-uploading-to-amazon-s3). Most of the code in this gem was extracted from [gallery-jquery-fileupload](https://github.com/railscasts/383-uploading-to-amazon-s3/tree/master/gallery-jquery-fileupload). 

Thank you Ryan Bates!

This code also uses the excellecnt [jQuery-File-Upload](https://github.com/blueimp/jQuery-File-Upload), which is included in this gem by its rails counterpart [jquery-fileupload-rails](https://github.com/tors/jquery-fileupload-rails)
