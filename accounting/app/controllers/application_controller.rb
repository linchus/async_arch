class ApplicationController < ActionController::Base
  def current_user
    request.env['warden'].user
  end

  def require_user_logged_in!
    redirect_to '/' if current_user.nil?
  end
end
