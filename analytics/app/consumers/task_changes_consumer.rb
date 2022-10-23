# frozen_string_literal: true

# Example consumer that prints messages payloads
class TaskChangesConsumer < ApplicationConsumer
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
    when 'Task.Created'
      Task.create!(
        public_id: message['data']['public_id'],
        title: message['data']['title'],
        state: message['data']['state']
      )
    when 'Task.Updated' # CUD
      task = Task.find_by(public_id: message['data']['public_id'])
      return unless task

      task.update!(
        public_id: message['data']['public_id'],
        title: message['data']['title'],
        state: message['data']['state']
      )
    when 'Task.Resolved' # BE
      task = Task.find_by(public_id: message['data']['public_id'])
      return unless task

      task.update!(state: 'resolved')
    else
      # log
    end
  rescue => e
    puts "Processing failed: #{e}"
    puts message
  end
end
