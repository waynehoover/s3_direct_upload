require "spec_helper"

describe S3DirectUpload::UploadHelper::S3Uploader do
  describe "policy_data" do

    describe "starts-with $key" do
      it "is configurable with the key_starts_with option" do
        key_starts_with = "uploads/"
        s3_uploader = S3DirectUpload::UploadHelper::S3Uploader.new({:key_starts_with => key_starts_with})
        s3_uploader.policy_data[:conditions].should include ["starts-with", "$key", key_starts_with]
      end

      it "defaults to 'uploads/'" do
        s3_uploader = S3DirectUpload::UploadHelper::S3Uploader.new({})
        s3_uploader.policy_data[:conditions].should include ["starts-with", "$key", "uploads/"]
      end
    end
  end
end