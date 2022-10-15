# frozen_string_literal: true

Rails.application.config.middleware.insert_after ActionDispatch::Session::CookieStore, Warden::Manager do |manager|
  manager.default_strategies :password
end

Warden::Manager.serialize_into_session do |account|
  account.id
end

Warden::Manager.serialize_from_session do |id|
  Account.find(id)
end
