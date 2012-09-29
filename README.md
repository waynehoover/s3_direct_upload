# S3DirectUpload

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 's3_direct_upload'

Then add a new initalizer with this code:
```
S3DirectUpload.config do |c|
  c.access_key_id = ""       # your access key id
  c.secret_access_key = ""   # your secret access key
  c.bucket = ""              # your bucket name
end
```

S3 Cors Config should look like this:
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

This gem requires the gem "jquery-fileupload-rails", which is already included by the gem.

You will need to add the following jquery-fileupload assets to your asset pipeline:

application.js
```
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
```
## Usage

Create a new view that uses the helper:
```
<%= s3_uploader_form post: paintings_url, as: "painting[image_url]" do %>
  <%= file_field_tag :file, multiple: true %>
<% end %>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
