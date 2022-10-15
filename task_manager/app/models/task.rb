class Task < ApplicationRecord
  belongs_to :assigned_to, class_name: 'Account'
  belongs_to :created_by, class_name: 'Account'

  validates :assigned_to, presence: true
  validates :created_by, presence: true

  enum state: {
    pending: 'pending',
    resolved: 'resolved'
  }

  def initialize(*, **)
    super

    self.state ||= :pending
    self.public_id ||= SecureRandom.uuid
  end
end
