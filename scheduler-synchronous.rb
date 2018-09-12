#!/usr/bin/env ruby
require_relative './helpers/connection'
include Setup

connection = make_connection
connection.start
client = make_http_connection(connection)

channel = connection.create_channel
sending_queue = channel.queue("send", durable: true)

number_of_emails_per_batch = 10

#puts client.list_queues.map {|q| [q.name, q.messages_ready] }

queues_to_shovel =  client.list_queues.select {|q| q.name.start_with?('quarantine.') && q.messages_ready.to_i > number_of_emails_per_batch }.map {|q| [q.name, q] }


queues_to_shovel.each do |queue_to_shovel|
  queue_name, queue_properties = queue_to_shovel  

  puts "\nProccessing queue: #{queue_name} with #{queue_properties.messages_ready} messages"
  queue = channel.queue(queue_name, durable: true)
  number_of_emails_per_batch.times do
    delivery_info, properties, body = queue.pop
    message_id = properties.to_h.fetch(:message_id)
    puts message_id
    sending_queue.publish(body, message_id: message_id)
  end  
end
