class Account < ApplicationRecord
  DEFAULT_CURRENCY = 'INR'
  belongs_to :user
  has_many :statements
end
