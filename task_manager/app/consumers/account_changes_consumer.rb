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
      when 'Account.Created'
        account = fetch_account(message['data']['public_id']) || Account.new
        account.update(
          public_id: message['data']['public_id'],
          email: message['data']['email'],
          full_name: message['data']['full_name'],
          role: message['data']['position']
        )
      when 'Account.Updated'
        fetch_account(message['data']['public_id'])&.update!(
          full_name: message['data']['full_name']
        )
      when 'Account.Deleted'
        fetch_account(message['data']['public_id'])&.destroy!
        # TODO: if you want
      when 'Account.RoleChanged'
        fetch_account(message['data']['public_id'])&.update!(
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


  private

  def fetch_account(p_id)
    Account.find_by(public_id:p_id)
  end
end
