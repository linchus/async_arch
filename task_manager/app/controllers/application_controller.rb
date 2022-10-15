class ApplicationController < ActionController::Base
  def current_account
    request.env['warden'].user
  end

  def require_user_logged_in!
    redirect_to '/' if current_account.nil?
  end
end
