module S3DirectUpload
  module UploadHelper
    def s3_uploader_form(options = {}, &block)
      uploader = S3Uploader.new(options)
      form_tag(uploader.url, uploader.form_options) do
        uploader.fields.map do |name, value|
          hidden_field_tag(name, value)
        end.join.html_safe + capture(&block)
      end
    end

    class S3Uploader
      def initialize(options)
        @key_starts_with = options[:key_starts_with] || "uploads/"
        @options = options.reverse_merge(
          aws_access_key_id: S3DirectUpload.config.access_key_id,
          aws_secret_access_key: S3DirectUpload.config.secret_access_key,
          bucket: options[:bucket] || S3DirectUpload.config.bucket,
          region: S3DirectUpload.config.region || "us-east-1",
          url: S3DirectUpload.config.url,
          ssl: true,
          acl: "public-read",
          expiration: 10.hours.from_now.utc.iso8601,
          max_file_size: 500.megabytes,
          callback_method: "POST",
          callback_param: "file",
          key_starts_with: @key_starts_with,
          key: key,
          date: Time.now.utc.strftime("%Y%m%d"),
          timestamp: Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
        )
      end

      def hostname
        if @options[:region] == "us-east-1"
          "#{@options[:bucket]}.s3.amazonaws.com"
        else
          "#{@options[:bucket]}.s3-#{@options[:region]}.amazonaws.com"
        end
      end

      def form_options
        {
          id: @options[:id],
          class: @options[:class],
          method: "post",
          authenticity_token: false,
          multipart: true,
          data: {
            callback_url: @options[:callback_url],
            callback_method: @options[:callback_method],
            callback_param: @options[:callback_param]
          }.reverse_merge(@options[:data] || {})
        }
      end

      def fields
        {
          :acl => @options[:acl],
          :key => @options[:key] || key,
          :policy => policy,
          :success_action_status => "201",
          'X-Amz-Algorithm' => 'AWS4-HMAC-SHA256',
          'X-Amz-Credential' => "#{@options[:aws_access_key_id]}/#{@options[:date]}/#{@options[:region]}/s3/aws4_request",
          'X-Amz-Date' => @options[:timestamp],
          'X-Amz-Signature' => signature,
          'X-Requested-With' => 'xhr'
        }
      end

      def key
        @key ||= "#{@key_starts_with}{timestamp}-{unique_id}-#{SecureRandom.hex}/${filename}"
      end

      def url
        @options[:url] || "http#{@options[:ssl] ? 's' : ''}://#{hostname}/"
      end

      def policy
        Base64.encode64(policy_data.to_json).gsub("\n", "")
      end

      def policy_data
        {
          expiration: @options[:expiration],
          conditions: [
            ["starts-with", "$utf8", ""],
            ["starts-with", "$key", @options[:key_starts_with]],
            ["starts-with", "$x-requested-with", ""],
            ["content-length-range", 0, @options[:max_file_size]],
            ["starts-with","$content-type", @options[:content_type_starts_with] ||""],
            {bucket: @options[:bucket]},
            {acl: @options[:acl]},
            {success_action_status: "201"},
            {'X-Amz-Algorithm' => 'AWS4-HMAC-SHA256'},
            {'X-Amz-Credential' => "#{@options[:aws_access_key_id]}/#{@options[:date]}/#{@options[:region]}/s3/aws4_request"},
            {'X-Amz-Date' => @options[:timestamp]}
          ] + (@options[:conditions] || [])
        }
      end

      def signing_key
        #AWS Signature Version 4
        kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + @options[:aws_secret_access_key], @options[:date])
        kRegion  = OpenSSL::HMAC.digest('sha256', kDate, @options[:region])
        kService = OpenSSL::HMAC.digest('sha256', kRegion, 's3')
        kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")

        kSigning
      end

      def signature
        OpenSSL::HMAC.hexdigest('sha256', signing_key, policy)
      end
    end
  end
end
