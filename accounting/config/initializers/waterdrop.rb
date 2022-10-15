# require 'water_drop'
# require 'water_drop/sync_producer'

# WaterDrop.setup do |config|
#   config.deliver = true
#   config.kafka.seed_brokers = ['kafka://localhost:9092']
# end

KAFKA_PRODUCER = WaterDrop::Producer.new

KAFKA_PRODUCER.setup do |config|
  config.kafka = { 'bootstrap.servers': 'localhost:9092' }
end
