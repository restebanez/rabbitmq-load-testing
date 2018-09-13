#!/usr/bin/env ruby
require_relative './helpers/connection'
include Setup

connection = make_connection
connection.start
client = make_http_connection(connection)

total_count = 0
quarantine_count = 0
all_count = 0
send_count = 0
client.list_queues.each do |q|
    total_count += q.messages_ready.to_i
    quarantine_count += q.messages_ready.to_i if q.name.start_with?('quarantine.')
    all_count += q.messages_ready.to_i if q.name.start_with?('all')
    send_count += q.messages_ready.to_i if q.name.start_with?('send')
end

puts "Quarantine Count: #{quarantine_count}"
puts "All Count: #{all_count}"
puts "Send Count: #{send_count}"
puts "Total Count #{total_count}"


