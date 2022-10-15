module ApplicationHelper
  def current_account
    request.env['warden'].user
  end

  def authenticated?(scope = nil)
    request.env['warden'].authenticated?
  end
end
