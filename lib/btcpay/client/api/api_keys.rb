# frozen_string_literal: true

module BtcPay
  module Client
    module Api
      class ApiKeys < Base
        PATH = '/api-keys'

        # @see https://docs.btcpayserver.org/API/Greenfield/v1/#tag/Authorization/paths/~1api-keys~1authorize/get
        def authorize(permissions: [], application_name:, strict: true, selective_stores: false, **opts)
          opts.merge!(
            {
              permissions: Array(permissions),
              applicationName: application_name,
              strict: strict,
              selectiveStores: selective_stores
            }
          )

          client.get('/api-keys/authorize', options: opts, include_api_path: false)
        end

        # @see https://docs.btcpayserver.org/API/Greenfield/v1/#tag/API-Keys/paths/~1api~1v1~1api-keys~1current/get
        def current(**opts)
          client.get(path('current'), options: opts)
        end

        alias get current
        alias info current

        # @see https://docs.btcpayserver.org/API/Greenfield/v1/#tag/API-Keys/paths/~1api~1v1~1api-keys/post
        def create(payload, **opts)
          client.post(path, payload: payload, options: opts)
        end

        # @see https://docs.btcpayserver.org/API/Greenfield/v1/#tag/API-Keys/paths/~1api~1v1~1api-keys~1{apikey}/delete
        def revoke(key, **opts)
          client.delete(path(key), options: opts)
        end

        alias delete revoke

        # https://docs.btcpayserver.org/API/Greenfield/v1/#tag/API-Keys/paths/~1api~1v1~1api-keys~1current/delete
        def revoke!(**opts)
          client.delete(path('current'), options: opts)
        end

        alias delete! revoke!

        protected

        def base_path
          PATH
        end
      end
    end
  end
end
