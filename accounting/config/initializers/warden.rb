# frozen_string_literal: true

Rails.application.config.middleware.insert_after ActionDispatch::Session::CookieStore, Warden::Manager do |manager|
  manager.default_strategies :password
end

Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find(id)
end
