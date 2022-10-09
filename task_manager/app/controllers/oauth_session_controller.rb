class OauthSessionController < ApplicationController
  def destroy
  end

  def create
    puts request.env['omniauth.auth']
    account = fetch_account || create_account

    request.env['warden'].set_user(account)
    redirect_to '/'
  end

  private

  def fetch_account
    auth = AuthProvider.where(provider: request.env['omniauth.auth'].provider, uid: request.env['omniauth.auth'].uid).take
    return unless auth

    auth.account
  end

  def create_account
    Account.transaction do
      account = Account.create!(
        public_id: payload['info']['public_id'],
        full_name: payload['info']['full_name'],
        email: payload['info']['email'],
        role: payload['info']['role']
      )
      account.auth_providers.create!(
        uid: payload.uid,
        provider: payload.provider,
        username: payload['info']['email'],
        user_info: payload.to_h
      )
    end
  end

  def payload
    request.env['omniauth.auth']
  end
end
