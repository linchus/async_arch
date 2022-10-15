class User < ApplicationRecord
  has_many :auth_providers

  EXECUTOR_ROLES = %w[employee]

  scope :executors, -> { where(role: EXECUTOR_ROLES) }

  scope :random, -> { order("random()") }
end
