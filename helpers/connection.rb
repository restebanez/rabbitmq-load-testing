require 'rubygems'
require 'bundler'
Bundler.setup(:default, :ci)
require 'dotenv/load'
require 'bunny'
require "rabbitmq/http/client"


module Setup
  def make_connection
    connection = Bunny.new(ENV['RABBITMQ_URL'], automatically_recover: false)
    puts "Connecting to #{connection.hostname}:#{connection.port} with vhost: #{connection.vhost}"
    connection
  end

  def make_http_connection(connection)
    RabbitMQ::HTTP::Client.new("http://#{connection.host}:15672", :username => connection.user, :password => connection.pass)
  end  

end