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

**application.js.coffee**
```coffeescript
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

Then in your application.js.coffee, call the S3Uploader jQuery plugin on the element you created above:
```coffeescript
jQuery ->
  $("#myS3Uploader").S3Uploader()
```

Also place this template in the same view for the progress bars:
```js+erb
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

`id:` -> html id for the form, its recommended that you give the form an id so you can reference with the jQuery plugin.

`class:` -> optional html class for the form.


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

`path` -> manual path for the files on your s3 bucket. Example: `path/to/my/files/on/s3`

Note: the file path in your s3 bucket will effectively be `path + key`.

`extra_data` -> You can send additional data to your rails app in the persistence POST request. Example: `{key: value}`

This would be accessible in your params hash as  `params[:extra_data][:key]`

`before_add` -> Callback function that executes before a file is added to the que. It is passed file object and expects `true` or `false` to be returned.

This could be useful if you would like to validate the filenames of files to be uploaded for example. If true is returned file will be uploaded as normal, false will cancel the upload.

### Public methods
You can change the settings on your form later on by accessing the jQuery instance:

```cofeescript
jQuery ->
  v = $("#myS3Uploader").S3Uploader()
  ...
  v.path = "new/path/"
  v.exta_data = "newdata"

### Global Event Hooks

When all uploads finish in a batch an `s3_uploads_complete` event will be triggered on `document`, so you could do something like:
```javascript
$(document).bind('s3_uploads_complete', function(){
    ...
    alert("All Uploads completed")
}); 
````
### Example with all options.
```cofeescript
jQuery ->
  $("#myS3Uploader").S3Uploader
    path: 'path/to/my/files/on/s3'
    extra_data: {key: 'value'}
    before_add: myCallBackFunction() # must return true or false if set
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