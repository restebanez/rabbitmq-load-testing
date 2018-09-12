#!/usr/bin/env ruby

require_relative './helpers/connection'
include Setup

def get_user_id
   user_ids = (34000..34100).to_a
   user_ids[rand(user_ids.count)]
end

def get_message
  messages = %w(hola hello bonjour Hallo Sveiki)
  messages[rand(messages.count)]
end  

connection = make_connection
connection.start

channel = connection.create_channel
# The default exchange is implicitly bound to every queue, with a routing key equal to the queue name. 
# It is not possible to explicitly bind to, or unbind from the default exchange. It also cannot be deleted.
queue = channel.queue('all', durable: true)


exit_requested = false
Kernel.trap( "INT" ) { exit_requested = true }
users = {}


while !exit_requested
  current_user_id = get_user_id
  users[current_user_id] ||= {count: 0 ,content: get_message}
  users[current_user_id][:count] += 1
  count, content = users[current_user_id].fetch_values(:count, :content)
  # http://rubybunny.info/articles/exchanges.html -> Message metadata
  message_id = "#{current_user_id}:#{count}"
  queue.publish(content, persistent: true, message_id: message_id)

  puts " [x] Sent ID: #{message_id} '" + content + "'"
  sleep 0.1
end
print "Exit was requested by user\n"



connection.close
