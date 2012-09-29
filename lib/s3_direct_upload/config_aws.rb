require "singleton"

module S3DirectUpload
  class Config
    include Singleton

    ATTRIBUTES = [:access_key_id, :secret_access_key, :bucket]

    attr_accessor *ATTRIBUTES
  end

  def self.config
    if block_given?
      yield Config.instance
    end
    Config.instance
  end
end