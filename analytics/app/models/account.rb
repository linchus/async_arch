class Account < ApplicationRecord
  has_many :auth_providers

  def admin?
    role == 'admin'
  end
end
