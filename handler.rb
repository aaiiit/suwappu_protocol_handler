#!/usr/bin/env ruby

require 'logger'

file = File.open('/home/tom/Code/suwappu/suwappu_protocol_handler/log/suwappu.log', File::WRONLY | File::APPEND)
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
		take_picture argument
	when 'scan'
		scan argument
	else
		puts "Command #{command} not found!"
	end
end

def download(uri)
	file_name = "barcode-#{Time.now.to_i}.pdf"
	@logger.info "Downloading #{uri} --> /home/tom/Code/suwappu/suwappu_protocol_handler/tmp/documents/#{file_name}"
	cmnd = "curl #{uri} -o '/home/tom/Code/suwappu/suwappu_protocol_handler/tmp/documents/#{file_name}'" 
	@logger.info cmnd
	system cmnd
	file_name
end

def print_barcode(local_doc)
	cmnd = "lpr -P 'Zebra-LP2824' /home/tom/Code/suwappu/suwappu_protocol_handler/tmp/documents/#{local_doc}"
	@logger.info cmnd
	system cmnd
end

def storage_slot(device,slot)
	cmnd = "lcdoctl -d 'Dacal DC-300:#{device}' -e #{slot}"
	@logger.info "Storage :: Slot #{slot} @ #{device}"
	@logger.info cmnd
	system cmnd
	system "sleep 10; lcdoctl -d 'Dacal DC-300:#{device}' -i #{slot}"
end

def take_picture(swap_number)
	cmnd = "streamer -o /tmp/#{swap_number}.jpeg && scp /tmp/#{swap_number}.jpeg deployer@inventorycontrol:/u/apps/inventorycontrol/shared/images/"
	@logger.info "take_picture"
	@logger.info cmnd
	system cmnd
end

def scan(swap_number)
	scanner = 'hpaio:/net/HP_Color_LaserJet_2840?ip=192.168.11.31'
	file = "/tmp/#{swap_number}"
	cmnd = "scanimage -d #{scanner}	--resolution=300 > #{file}.pnm"
	@logger.info "scan"
	@logger.info cmnd
	system cmnd
	cmnd = "pnmtops #{file}.pnm > #{file}.ps"
	@logger.info cmnd
	system cmnd
	cmnd = "ps2pdf #{file}.ps #{file}.pdf"
	@logger.info cmnd
	system cmnd
end

argument = ARGV[0]
puts argument
puts analyze_uri(argument)
@logger.close

