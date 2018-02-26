module S3DirectUpload
  module UploadHelper
    def s3_uploader_form(options = {}, &block)
      uploader = S3Uploader.new(options)
      content_tag(:div, uploader.wrapper_options) do
        uploader.fields.map do |name, value|
          hidden_field_tag(name, value)
        end.join.html_safe + capture(&block)
      end
    end

    alias_method :s3_uploader, :s3_uploader_form

    def s3_uploader_url ssl = true
      S3DirectUpload.config.url || "http#{ssl ? 's' : ''}://#{S3DirectUpload.config.region || 's3'}.amazonaws.com/#{S3DirectUpload.config.bucket}/"
    end

    class S3Uploader
      def initialize(options)
        @key_starts_with = options[:key_starts_with] || 'uploads/'
        @date = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
        @options = options.reverse_merge(
          aws_access_key_id: S3DirectUpload.config.access_key_id,
          aws_secret_access_key: S3DirectUpload.config.secret_access_key,
          bucket: options[:bucket] || S3DirectUpload.config.bucket,
          ssl: true,
          acl: "public-read",
          expiration: 10.hours.from_now.utc.iso8601,
          max_file_size: 500.megabytes,
          callback_method: "POST",
          callback_param: "file",
          key_starts_with: @key_starts_with,
          key: key,
          server_side_encryption: nil,
          conditions: []
        )
      end

      def wrapper_options
        {
          id: @options[:id],
          class: @options[:class],
          data: {
            callback_url: @options[:callback_url],
            callback_method: @options[:callback_method],
            callback_param: @options[:callback_param]
          }.reverse_merge(@options[:data] || {})
        }
      end

      def fields
        {
          :key => @options[:key] || key,
          :policy => policy,
          'x-amz-signature' => signature
        }.merge(common_fields)
      end

      # fields that must be included both as form data and as conditions in policy
      def common_fields
        {
          acl: @options[:acl],
          success_action_status: '201',
          'X-Requested-With' => 'xhr',
          'x-amz-server-side-encryption' => @options[:server_side_encryption],
          'x-amz-algorithm' => 'AWS4-HMAC-SHA256',
          'x-amz-credential' => credential,
          'x-amz-date' => @date
        }.compact
      end

      def key
        @key ||= "#{@key_starts_with}{timestamp}-{unique_id}-#{SecureRandom.hex}/${filename}"
      end

      def policy
        Base64.encode64(policy_data.to_json).gsub("\n", '')
      end

      def policy_data
        {
          expiration: @options[:expiration],
          conditions: [
            ["starts-with", "$key", @options[:key_starts_with]],
            ["starts-with", "$x-requested-with", ""],
            ["content-length-range", 0, @options[:max_file_size]],
            ["starts-with","$content-type", @options[:content_type_starts_with] || ''],
            {bucket: @options[:bucket]}
          ] + @options[:conditions] + common_fields.to_a.map { |k, v| { k => v } }
        }
      end

      def credential
        [
          @options[:aws_access_key_id],
          @date[0, 8],
          S3DirectUpload.config.region || 's3',
          's3',
          'aws4_request'
        ].join('/')
      end

      def signature
        k_date = hmac('AWS4' + @options[:aws_secret_access_key], Time.now.utc.strftime('%Y%m%d'))
        k_region = hmac(k_date, S3DirectUpload.config.region || 's3')
        k_service = hmac(k_region, 's3')
        k_creds = hmac(k_service, 'aws4_request')
        OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new('sha256'),
          k_creds,
          policy
        )
      end

      def hmac(key, value)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
      end
    end
  end
end
