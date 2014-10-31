module Sorcery
  module Providers
    # This class adds support for OAuth with Wordpress
    #
    #   ...
    #
    class Wordpress < Base

      include Protocols::Oauth2

      def initialize
        super
        @authorize_path = '/oauth/authorize'
        @request_token_path = '/oauth/request_token'
        @user_info_path = '/oauth/request_access'
        @state = 'something'
        @user_info_mapping = {
          email: 'user_email',
          name: 'display_name'
        }
      end

      def login_url(params, session)
        authorize_url({client_id: @key})
      end

      def get_consumer
        ::OAuth::Consumer.new(@key, @secret, site: @site, authorize_path: @authorize_path)
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: @request_token_path, token_method: :post)
      end

      def get_user_hash(access_token, code)
        response = access_token.get(@user_info_path, params: { access_token: access_token.token })
        {}.tap do |h|
          h[:user_info] = JSON.parse(response.body)
          h[:uid] = h[:user_info]['ID'].to_s
        end
      end
    end
  end
end
