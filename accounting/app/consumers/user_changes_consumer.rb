# frozen_string_literal: true

# Example consumer that prints messages payloads
class UserChangesConsumer < ApplicationConsumer
  def consume
    messages.each do |m|
      message = m.payload
      puts '-' * 80
      p message
      puts '-' * 80

      case message['event_name']
      when 'Account.Created'
        user = fetch_user(message['data']['public_id'])
        if user
          user.update(
            public_id: message['data']['public_id'],
            email: message['data']['email'],
            full_name: message['data']['full_name'],
            role: message['data']['position']
          )
        else
          create_user(message['data'])
        end
      when 'Account.Updated'
        fetch_user(message['data']['public_id'])&.update!(
          full_name: message['data']['full_name']
        )
      when 'Account.Deleted'
        fetch_user(message['data']['public_id'])&.destroy!
        # TODO: if you want
      when 'Account.RoleChanged'
        fetch_user(message['data']['public_id'])&.update!(
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

  def fetch_user(p_id)
    User.find_by(public_id:p_id)
  end

  def create_user(data)
    User.transaction do
      user = User.create!(
        public_id: data['public_id'],
        email: data['email'],
        full_name: data['full_name'],
        role: data['position']
      )
      user.accounts.create!(
        public_id: SecureRandom.uuid,
        label: 'Default user account',
        currency: Account::DEFAULT_CURRENCY
      )
      user
    end
  end
end
