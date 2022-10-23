# frozen_string_literal: true

# Example consumer that prints messages payloads
class StatementChangesConsumer < ApplicationConsumer
  def consume
    messages.each do |m|
      message = m.payload
      puts '-' * 80
      p message
      puts '-' * 80

      process_message(message)
    end
  end

  private

  def process_message(message)
    case message['event_name']
    when 'Statement.Created'
      Statement.create!(
        account_public_id: message['data']['owner']['public_id'],
        description: message['data']['description'],
        credit: message['data']['credit'],
        debit: message['data']['debit'],
        ref_type: message['data']['ref_type'],
        ref_public_id: message['data']['ref_public_id']
      )
    else
      # store events in DB
    end
  rescue => e
    puts "Processing failed: #{e}"
    puts message
  end
end
