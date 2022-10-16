# frozen_string_literal: true

# Example consumer that prints messages payloads
class TaskChangesConsumer < ApplicationConsumer
  def consume
    messages.each do |m|
      message = m.payload
      puts '-' * 80
      p message
      puts '-' * 80
    end
  end
end
