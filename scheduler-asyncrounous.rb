#!/usr/bin/env ruby
require_relative './helpers/connection'
include Setup

connection = make_connection
connection.start
client = make_http_connection(connection)


#channel = connection.create_channel
#sending_queue = channel.queue("send", durable: true)


number_of_emails_per_batch = 10

queues_to_shovel =  client.list_queues.select {|q| q.name.start_with?('quarantine.') && q.messages_ready > 10 }.map {|q| [q.name, q] }

channels = {}
consumers = {}
cancels = {}

queues_to_shovel.each do |queue_to_shovel|
  queue_name, queue_properties = queue_to_shovel  

  puts "\nProccessing queue: #{queue_name} with #{queue_properties.messages_ready} messages"
  first = nil
  last = nil
  count = 0
  channels[queue_name] = connection.create_channel
  cancels[queue_name] = false

  consumers[queue_name] = channels[queue_name].queue(queue_name, durable: true).subscribe(manual_ack: true) do |delivery_info, properties, body|
    message_id = properties.to_h.fetch(:message_id)
    #user_id, count = message_id.split(':')
    #first ||= count.to_i
    #last ||= first + number_of_emails_per_batch
    if count < number_of_emails_per_batch
      count+=1 
      print ".#{count}"
      channels[queue_name].ack(delivery_info.delivery_tag)
      channels[queue_name].queue("send", durable: true).publish(body, message_id: message_id)
    else
      print "-#{count}"
      cancels[queue_name] = true
    end  
  end
  puts "Consumer: #{consumers[queue_name].consumer_tag} created"
  sleep 0.1
  until cancels[queue_name]
  	print '*'
  end
  cancel_ok = consumers[queue_name].cancel
  puts "Consumer: #{cancel_ok.consumer_tag} cancelled"
  #sleep 1
  channels[queue_name].close 	


end
