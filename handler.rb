#!/home/tom/.rvm/rubies/ruby-2.0.0-p481/bin/ruby

require 'logger'
require 'base64'
require 'rubygems'
require 'ffi-rzmq'

dir = File.dirname(__FILE__)
file = File.open("#{dir}/log/suwappu.log", File::WRONLY | File::APPEND)
ASSETS_DIR = "/mnt/Data/Assets"

@logger = Logger.new(file)
@logger.level = Logger::INFO

def analyze_uri(uri)
	command_and_uri = uri.split(/\/\//)[1]

	i = command_and_uri.index(/\//)
	command = command_and_uri[0..i-1]
	i = (command_and_uri.length - i - 1)*-1
	argument = command_and_uri[i..-1]

	case command
	when 'print'
		uri = "http://#{argument}"
		print_barcode download(uri)
	when 'storage'
		checkpoint, device, slot = argument.split('/')
		storage_slot device,slot
	when 'picture'
    print_barcode argument,argument
		#take_picture argument
	when 'scan'
		scan argument
	else
		puts "Command #{command} not found!"
	end
end

def event_completed(command,argument)
  @logger.info "Event suwappu_handler##{command}_completed called"
end

def download(uri)
	file_name = "barcode-#{Time.now.to_i}.pdf"
	@logger.info "Downloading #{uri} --> /home/tom/Code/suwappu/suwappu_protocol_handler/tmp/documents/#{file_name}"
	cmnd = "curl #{uri} -o '/home/tom/Code/suwappu/suwappu_protocol_handler/tmp/documents/#{file_name}'" 
	@logger.info cmnd
	system cmnd
	file_name
end

def print_barcode(barcode,label)
	#cmnd = "lpr -P 'Zebra-LP2824' /home/tom/Code/suwappu/suwappu_protocol_handler/tmp/documents/#{local_doc}"
  system "touch /tmp/1"
  ctx = ZMQ::Context.new()
  socket = ctx.socket(ZMQ::PUB)
  socket.bind('tcp://192.168.11.5:7001')
  socket.bind("ipc://pubz.ipc")
  system "touch /tmp/2"
  sleep 1.5 # HACK : To make sure the connection is setup
  puts "Printing #{barcode} with label #{label}"
  socket.send_string("#{barcode};#{label}")
  puts "Printed"
  socket.close 
  system "touch /tmp/3"
	#@logger.info cmnd
	#system cmnd
	#event_completed('print_barcode',{file: local_doc})
end

def zmq_pub(address,filter,msg)
end

def storage_slot(device,slot)
	cmnd = "lcdoctl -d 'Dacal DC-300:#{device}' -e #{slot}"
	@logger.info "Storage :: Slot #{slot} @ #{device}"
	@logger.info cmnd
	system cmnd
	system "sleep 10; lcdoctl -d 'Dacal DC-300:#{device}' -i #{slot}"
end

def take_picture(swap_number)
	cmnd = "streamer -o /tmp/#{swap_number}.jpeg && scp /tmp/#{swap_number}.jpeg deployer@inventorycontrol:/u/apps/inventorycontrol/shared/suwappu_pictures/"
	@logger.info "take_picture"
	@logger.info cmnd
	system cmnd
	event_completed('take_picture',{swap_number: swap_number,file: "file:///tmp/#{swap_number}.jpeg"})
end

def scan(uuid)
  scanner = 'hpaio:/net/HP_Color_LaserJet_2840?ip=192.168.11.31'
  file = "#{ASSETS_DIR}/#{uuid}"
  cmnd = "scanimage -d #{scanner} -l 0 -t 0 -x 215 -y 297 --resolution=300 > #{file}.pnm"
  @logger.info "scan"
  @logger.info cmnd
  system cmnd
  #cmnd = "pnmtops #{file}.pnm > #{file}.ps"
  #@logger.info cmnd
  #system cmnd
  #cmnd = "ps2pdf #{file}.ps #{file}.pdf"
  #@logger.info cmnd
  #system cmnd
  imgBase64 = Base64.encode64(open("#{file}.pnm") { |io| io.read })
  event_completed('scan',{uuid: uuid,file: "#{file}.pnm"})
  "#{file}.pnm"
end

argument = ARGV[0]
puts argument
puts analyze_uri(argument)
@logger.close

