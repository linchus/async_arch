class Account < ApplicationRecord
  has_many :auth_providers
end
