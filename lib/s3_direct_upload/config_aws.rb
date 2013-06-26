require "singleton"

module S3DirectUpload
  class Config
    include Singleton

    ATTRIBUTES = [:access_key_id, :secret_access_key, :bucket, :prefix_to_clean, :region, :url]

    attr_accessor *ATTRIBUTES

    def self.aws_access_key_id
      if self.access_key_id.blank?
        return AWS.config().credentials()['access_key_id'] if Object.const_defined?('AWS')
      else
        self.access_key_id
      end
    end

    def self.aws_secret_access_key
      if self.secret_access_key.blank?
        return AWS.config().credentials()['secret_access_key'] if Object.const_defined?('AWS')
      else
        self.secret_access_key
      end
    end
  end

  def self.config
    if block_given?
      yield Config.instance
    end
    Config.instance
  end
end
