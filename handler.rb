#!/home/tom/.rvm/rubies/ruby-1.9.2-p320/bin/ruby

require 'logger'
require 'pusher'
require '/home/tom/Code/pusher-ruby-client'
#require 'pusher-client'

file = File.open('/home/tom/Code/suwappu/suwappu_protocol_handler/log/suwappu.log', File::WRONLY | File::APPEND)
@logger = Logger.new(file)
@logger.level = Logger::INFO
Pusher.app_id = 45972
Pusher.key = '71ea26969299b55eca1a'
Pusher.secret = '063c8f72e55c99814a02' 
Pusher.host = 'pusher'
Pusher.port = 4567

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

def event_completed(command,argument)
	begin
		Pusher['suwappu_handler'].trigger("#{command}_completed",argument)
		@logger.info "Event suwappu_handler##{command}_completed called"
	rescue Pusher::Error => e
		puts e
		@logger.debug e
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
	event_completed('print_barcode',{file: local_doc})
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

def scan(uid)
	scanner = 'hpaio:/net/HP_Color_LaserJet_2840?ip=192.168.11.31'
	file = "/tmp/#{uid}"
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
	#event_completed('scan',{uid: uid,file: "#{file}.pdf"})
	event_completed('scan',{uid: uid,file: "#{file}.pdf"})
	"#{file}.pdf"
end

argument = ARGV[0]
puts argument
puts analyze_uri(argument)
@logger.close

