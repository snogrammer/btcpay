# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'multi_json'

module BtcPay
  module Client
    ##
    # Status object to capture result from an HTTP request
    #
    # Gives callers context of the result and allows them to
    # implement successful strategies to handle success/failure
    class Result
      def self.success(response)
        new(:success, response)
      end

      def self.failed(response)
        new(:failed, response)
      end

      attr_reader :body, :code, :headers, :raw, :status

      def initialize(status, response)
        @code = response.code
        @headers = response.headers # e.g. "Content-Type" will become :content_type.
        @status = status

        @raw = raw_parse(response.body)
        @body = rubify_body
      end

      def success?
        status == :success
      end

      def failure?
        !success?
      end

      def to_h
        {
          status: status,
          headers: headers,
          code: code,
          body: body
        }
      end

      alias to_hash to_h

      private

      def method_missing(method, *args, &blk)
        to_h.send(method, *args, &blk) || super
      end

      def respond_to_missing?(method, include_private = false)
        to_h.respond_to?(method) || super
      end

      # @param body [JSON] Raw JSON body
      def raw_parse(response)
        return if response.blank?

        body = MultiJson.load(response)
        return body.with_indifferent_access if body.respond_to?(:with_indifferent_access)
        raise NotImplemented.new('Unknown response type') unless body.is_a?(Array)

        key = success? ? :data : :errors
        {
          key => body.map(&:with_indifferent_access)
        }
      rescue MultiJson::ParseError
        response
      rescue StandardError => e
        raise ResponseBodyParseError.new(error: 'JSON parse error', message: e.message, body: response)
      end

      def rubify_body
        return if raw.blank?
        return unless raw.respond_to?(:deep_transform_keys)

        raw.deep_transform_keys { |key| key.to_s.underscore }.with_indifferent_access
      end

      class ResponseBodyParseError < StandardError; end
    end
  end
end
