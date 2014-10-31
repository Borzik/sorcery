module Sorcery
  module Providers
    # This class adds support for OAuth with Wordpress
    #
    #   ...
    #
    class Wordpress < Base

      include Protocols::Oauth

      attr_accessor :access_token_path, :authorize_path, :request_token_path,
                    :site, :callback_url


      def initialize
        @configuration = {
            token_url: '/oauth/request_token',
            access_url: "/oauth/request_access"
        }
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        {}.tap do |h|
          h[:user_info] = JSON.parse(response.body)['users'].first
          h[:uid] = user_hash[:user_info]['id'].to_s
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        authorize_url
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, token_method: :post)
      end

    end
  end
end
