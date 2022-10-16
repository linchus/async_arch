class User < ApplicationRecord
  has_many :auth_providers
  has_many :accounts
end
