#!/usr/bin/env ruby

require_relative './helpers/connection'
include Setup

connection = make_connection
connection.start

channel = connection.create_channel


# Declare both exchanges


all_queue = channel.queue('all', durable: true)

sending_queue = channel.queue("send", durable: true)

quarantine_queue_names = channel.queue("quarantine_queue_names", durable: true)



begin
  puts " [*] Waiting for messages in queue #{all_queue.name}. To exit press CTRL+C"
  all_queue.subscribe(block: true, manual_ack: false) do |delivery_info, properties, body|
    #puts " [x] Received in 'all' #{body}"
    message_id = properties.to_h.fetch(:message_id)
    user_id, count = message_id.split(':')

    if count.to_i < 3 
      #puts "\nuser##{user_id}, msg: #{count} enqueue to queue: #{sending_queue.name}"
      puts '>'
      #channel.ack(delivery_info.delivery_tag)
      sending_queue.publish(body, message_id: message_id)
    else
      quarantine_queue_name = "quarantine.#{user_id}"
      #puts "user##{user_id}, msg: #{count} enqueue to: #{quarantine_user_name} "
      print '.'
      channel.queue(quarantine_queue_name, durable: true).publish(body, message_id: message_id)
      #channel.ack(delivery_info.delivery_tag)
    end 
  end
rescue Interrupt => _
  connection.close
  exit(0)
end
