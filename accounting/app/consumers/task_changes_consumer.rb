# frozen_string_literal: true

# Example consumer that prints messages payloads
class TaskChangesConsumer < ApplicationConsumer
  def consume
    messages.each do |m|
      message = m.payload
      puts '-' * 80
      p message
      puts '-' * 80

      case message['event_name']
      when 'Task.Created' # CUD
        # ignore
      when 'Task.Updated' # CUD
        task = Task.find_by(public_id: message['data']['public_id'])
        next unless task

        task.update!(title: message['data']['title'])
      when 'Task.Added' # BE
        Task.transaction do
          task = Task.create!(
            public_id: message['data']['public_id'],
            title: message['data']['title']
          )
          user = User.find_or_create_by!(public_id: message['data']['assigned_to']['public_id'])
          account = user.accounts.take || user.accounts.create!(
            public_id: SecureRandom.uuid,
            label: 'Default user account',
            currency: Account::DEFAULT_CURRENCY
          )
          account.statements.create!(
            credit: task.assign_price,
            description: "#{task.title} assigned",
            ref: task
          )
          task
        end
      when 'Task.Resolved' # BE
        task = Task.find_by!(public_id: message['data']['public_id'])
        user = User.find_by!(public_id: message['data']['assigned_to']['public_id'])
        account = user.accounts.take
        account.statements.create!(
          debit: task.resolve_price,
          description: "#{task.title} resolved",
          ref: task
        )
        task
      end
    end
  end
end
