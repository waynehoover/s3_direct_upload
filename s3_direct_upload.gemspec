# -*- encoding: utf-8 -*-
require File.expand_path('../lib/s3_direct_upload/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Wayne Hoover"]
  gem.email         = ["w@waynehoover.com"]
  gem.description   = %q{Direct Upload to Amazon S3 With CORS and jquery-file-upload}
  gem.summary       = %q{Gives a form helper for Rails which allows direct uploads to s3. Based on RailsCast#383}
  gem.homepage      = ""

  gem.files         = Dir["{lib,app}/**/*"] + ["LICENSE", "README.md"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "s3_direct_upload"
  gem.require_paths = ["lib"]
  gem.version       = S3DirectUpload::VERSION

  gem.add_dependency 'rails', '>= 3.1'
  gem.add_dependency 'coffee-rails', '>= 3.1'
  gem.add_dependency 'sass-rails', '>= 3.1'
  gem.add_dependency 'jquery-fileupload-rails', '~> 0.4.1'
end
