require 'spec_helper'
describe S3DirectUpload do
  it "version must be defined" do
    S3DirectUpload::VERSION.should be_present
  end

  it "config must be defined" do
    S3DirectUpload.config.should be_present
  end

end