require 'faye'
require 'eventmachine'

DEVICE_ID=1
file = ARGV[0]

puts "Suwappu Hardware Input Client"

EM.run {
  client = Faye::Client.new('http://localhost:3000/faye')
  client.publish('/devices/completed',{metadata: {device_id: DEVICE_ID},data: {file: file}})
}
