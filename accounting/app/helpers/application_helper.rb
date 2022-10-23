module ApplicationHelper
  def current_user
    request.env['warden'].user
  end
end
