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

  def old_title
    attributes['title']
  end

  def title
    return if attributes['title'].nil?

    attributes['title'].split(/ - /).last
  end

  def jira_id
    return unless attributes['title'] =~ /\s\-\s/

    attributes['title'].split(/ - /).first
  end
end
