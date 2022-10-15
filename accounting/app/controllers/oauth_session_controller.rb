class OauthSessionController < ApplicationController
  def destroy
    request.env['warden'].set_user(nil)

    redirect_to '/'
  end

  def create
    puts request.env['omniauth.auth']
    user = fetch_user || create_user

    request.env['warden'].set_user(user)
    redirect_to '/'
  end

  private

  def fetch_user
    auth = AuthProvider.where(provider: request.env['omniauth.auth'].provider, uid: request.env['omniauth.auth'].uid).take
    return unless auth

    auth.user
  end

  def create_user
    User.transaction do
      user = User.find_by(public_id: payload['info']['public_id']) || User.create!(
        public_id: payload['info']['public_id'],
        full_name: payload['info']['full_name'],
        email: payload['info']['email'],
        role: payload['info']['role']
      )
      user.auth_providers.create!(
        uid: payload.uid,
        provider: payload.provider,
        username: payload['info']['email'],
        user_info: payload.to_h
      )
      user
    end
  end

  def payload
    request.env['omniauth.auth']
  end
end
