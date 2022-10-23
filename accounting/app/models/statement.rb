class Statement < ApplicationRecord
  belongs_to :account
  belongs_to :ref, polymorphic: true

  scope :totals, -> { select('SUM(credit) as total_credit, SUM(debit) as total_debit') }
  scope :today, -> { where('DATE(created_at) = CURRENT_DATE') }
  scope :for_date, ->(date) { where("DATE(created_at) = ?", date) }
  scope :task_related, -> { where(ref_type: 'Task') }

  after_create do
    statement = self
    event_name = 'Statement.Created'
    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_time: Time.now.to_s,
      producer: 'accounting_service',
      event_name: event_name,
      data: {
        owner: {public_id: statement.account.user.public_id},
        description: statement.description,
        credit: statement.credit || 0,
        debit: statement.debit || 0,
        ref_type: statement.ref_type,
        ref_public_id: statement.ref.public_id
      }
    }

    result = SchemaRegistry.validate_event(event, event_name.underscore, version: event[:event_version])

    if result.success?
      KAFKA_PRODUCER.produce_sync(topic: 'statements-stream', payload: event.to_json)
    else
      puts "Event validation error: #{result.failure}"
      puts "Event data: #{event.inspect}"
    end
  end
end
