# frozen_string_literal: true

# Example consumer that prints messages payloads
class AccountChangesConsumer < ApplicationConsumer
  def consume
    messages.each do |m|
      message = m.payload
      puts '-' * 80
      p message
      puts '-' * 80

      case message['event_name']
      when 'AccountCreated'
        # TODO: if you want
      when 'AccountUpdated'
        Account.find_by(public_id: message['data']['public_id'])&.update!(
          full_name: message['data']['full_name']
        )
      when 'AccountDeleted'
        # TODO: if you want
      when 'AccountRoleChanged'
        Account.find_by(public_id: message['data']['public_id'])&.update!(
          role: message['data']['role']
        )
      else
        # store events in DB
      end
    end
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
