# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Keepa < OmniAuth::Strategies::OAuth2
      option :name, :keepa

      option :client_options, {
          :site => "http://localhost:3000"
      }

      uid { raw_info["public_id"] }

      info do
        {
            :email => raw_info["email"],
            :full_name => raw_info["full_name"],
            :position => raw_info["position"],
            :active => raw_info["active"],
            :role => raw_info["role"],
            :public_id => raw_info["public_id"]
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/accounts/current').parsed
      end
    end
  end
end


Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :keepa,
    ENV['AUTH_KEY'] || 'Fq3p120BvGHAdxVlAGQIwibcZw36Nt-_c2CB31D7wDY',
    ENV['AUTH_SECRET'] || '23OIQxu73lmW9lFIS0s1SzGmGfTu1fAdq2RmDv1hZ-g',
    scope: 'public'
  )
end
