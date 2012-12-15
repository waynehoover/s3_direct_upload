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
```xml
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

**application.js.coffee**
```coffeescript
#= require jquery-fileupload/vendor/jquery.ui.widget
#= require jquery-fileupload/jquery.iframe-transport
#= require jquery-fileupload/jquery.fileupload
#= require s3_direct_upload
```

**application.css**
```css
//= require s3_direct_upload_progress_bars
```

## Usage
Create a new view that uses the form helper `s3_uploader_form`:
```ruby
<%= s3_uploader_form post: model_url, as: "model[image_url]", id: "myS3Uploader" do %>
  <%= file_field_tag :file, multiple: true %>
<% end %>
```

Then in your application.js.coffee, call the s3upload jQuery plugin on the element you created above:
```coffeescript
jQuery ->
  $("#myS3Uploader").s3upload()
```

Optionally, you can also place this template in the same view for the progress bars:
```js+erb
<script id="template-upload" type="text/x-tmpl">
<div class="upload">
  {%=o.name%}
  <div class="progress"><div class="bar" style="width: 0%"></div></div>
</div>
</script>
```

## Options for form helper
* `post:` url in which is POST'd to after file is uploaded to S3. If you don't specify this option, no callback to the server will be made after the file has uploaded to S3.
* `as:` parameter value for the POST in which the key will be the URL of the file on S3. If for example this is set to "model[image_url]" then the data posted would be `model[image_url] : http://bucketname.s3.amazonws.com/filename.ext`
* `key:` key on s3. defaults to `"uploads/#{SecureRandom.hex}/${filename}"`. needs to be at least `"${filename}"`.
* `acl:` acl for files uploaded to s3, defaults to "public-read"
* `max_file_size:` maximum file size, defaults to 500.megabytes
* `id:` html id for the form, its recommended that you give the form an id so you can reference with the jQuery plugin.
* `class:` optional html class for the form.
* `data:` Optional html data

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

Note: the POST request to the rails app also includes the following parameters `filesize`, `filetype`, `filename` and `filepath`.

### Advanced Customizations
Feel free to override the styling for the progress bars in s3_direct_upload_progress_bars.css, look at the source for inspiration.

Also feel free to write your own js to interface with jquery-file-upload. You might want to do this to do custom validations on the files before it is sent to S3 for example.
To do this remove `s3_direct_upload` from your application.js and include the necessary jquery-file-upload scripts in your asset pipeline (they are included in this gem automatically):
```cofeescript
#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl
```
Use the javascript in `s3_direct_upload` as a guide.


## Options for S3Upload jQuery Plugin

* `path:` manual path for the files on your s3 bucket. Example: `path/to/my/files/on/s3`  
  Note: the file path in your s3 bucket will effectively be `path + key`.
* `additional_data:` You can send additional data to your rails app in the persistence POST request. This would be accessable in your params hash as  `params[:key][:value]`  
  Example: `{key: value}` 
* `remove_completed_progress_bar:` By default, the progress bar will be removed once the file has been successfully uploaded. You can set this to `false` if you want to keep the progress bar.
* Supported callbacks (see below)

### Example with all options
```coffeescript
jQuery ->
  $("#myS3Uploader").s3upload
    path: 'path/to/my/files/on/s3'
    additional_data: {key: 'value'}
    remove_completed_progress_bar: false
    before_add: (e, data) ->
      return false unless (/(\.|\/)jpg$/i).test(data.file.type)
    start: (e, data) -> // Do sth
    done: (e, data) -> // Do sth
    fail: (e, data) -> // Do sth

```

### Change options
You can change the options on your form by using the `option` method:

```coffeescript
jQuery ->
  $("#myS3Uploader").s3upload("option", "additional_data", {foo: "bar"})
  $("#myS3Uploader").s3upload("option", "path", "new/path/")
```

### Javascript Event Hooks

The S3 upload widget provides two ways to use callback hooks:
```coffeescript
$('#myS3Uploader').s3upload(
  start: ->
    alert("start 1")
).on("s3uploadstart", ->
  alert("start 2")
)
```

#### File added
`before_add` is fired before a file is added to the queue. It passes the file object through `data.file` and expects `true` or `false` to be returned. This could be useful if you would like to validate the filenames of files to be uploaded for example. If true is returned file will be uploaded as normal, false will cancel the upload.
```coffeescript
$('#myS3Uploader').on 's3uploadbefore_add', (e, data) ->
  alert("Uploads have started")
```

#### Progress
During the upload process the `progress` event is fired. The callback receives a `data` object with the following attributes:

* `loaded`: Number of bytes already loaded
* `total`: Number of total bytes
* `percentage`: Percentage of loaded bytes

```coffeescript
$('#myS3Uploader').on 's3uploadprogress', (e, data) ->
  $(".bar").css("width", "#{data.percentage}%")
```

#### First upload started
`start` is fired once when any batch of uploads is starting.
```coffeescript
$('#myS3Uploader').on 's3uploadstart', (e) ->
  alert("Uploads have started")
```

#### Successfull upload
When a file has been successfully to S3, the `done` event is triggered on the form. A `data` object is passed along with the following attributes :

* `url`       The full URL to the uploaded file on S3.
* `filename`  The original name of the uploaded file.
* `filepath`  The path to the file (without the filename or domain)
* `filesize`  The size of the uploaded file.
* `filetype`  The type of the uploaded file.
* `filekey`   The S3 key of the uploaded file ("#{filepath}/#{filename}").

This hook could be used for example to fill a form hidden field with the returned S3 url :
```coffeescript
$('#myS3Uploader').on "s3uploaddone", (e, data) ->
  $('#someHiddenField').val(data.url)
```

#### Failed upload
When an error occured during the transferm the `fail` is triggered on the form with the same `data` object is passed for the successful upload with the addition of the `error_thrown` attribute. The most basic way to handle this error would be to display an alert message to the user in case the upload fails :
```coffeescript
$('#myS3Uploader').on "s3uploadfail", (e, data) ->
  alert("#{data.filename} failed to upload : #{data.error_thrown}")
```

## Cleaning old uploads on S3
You may be processing the files upon upload and reuploading them to another
bucket or directory. If so you can remove the originali files by running a
rake task.

First, add the fog gem to your `Gemfile` and run `bundle`:
```ruby
  require 'fog'
```

Then, run the rake task to delete uploads older than 2 days:
```
  $ rake s3_direct_upload:clean_remote_uploads
  Deleted file with key: "uploads/20121210T2139Z_03846cb0329b6a8eba481ec689135701/06 - PCR_RYA014-25.jpg"
  Deleted file with key: "uploads/20121210T2139Z_03846cb0329b6a8eba481ec689135701/05 - PCR_RYA014-24.jpg"
  $
```

Optionally customize the prefix used for cleaning (default is `uploads/#{2.days.ago.strftime('%Y%m%d')}`):
**config/initalizers/s3_direct_upload.rb**
```ruby
S3DirectUpload.config do |c|
  # ...
  c.prefix_to_clean = "my_path/#{1.week.ago.strftime('%y%m%d')}"
end
```

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
