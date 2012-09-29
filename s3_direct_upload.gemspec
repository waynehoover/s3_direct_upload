# -*- encoding: utf-8 -*-
require File.expand_path('../lib/s3_direct_upload/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Wayne"]
  gem.email         = ["wayne@blissofbeing.com"]
  gem.description   = %q{Direct Upload to Amazon S3 With CORS}
  gem.summary       = %q{Gives a form helper for Rails which allows direct uploads to s3}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "s3_direct_upload"
  gem.require_paths = ["lib"]
  gem.version       = S3DirectUpload::VERSION

  gem.add_dependency 'rails', '~> 3.2'
  gem.add_dependency 'jquery-fileupload-rails', '~> 0.3.4'
end
