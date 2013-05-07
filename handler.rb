#!/usr/bin/env ruby

require 'logger'

file = File.open('./log/suwappu.log', File::WRONLY | File::APPEND)
@logger = Logger.new(file)
@logger.level = Logger::INFO

def analyze_uri(uri)
	command_and_uri = uri.split(/\/\//)[1]
	if command_and_uri.start_with?('print/')
		# Print Command Invoked
		pdf_path = command_and_uri['print/'.length,command_and_uri.length-1]
		print_barcode download("http://#{pdf_path}")
	else
		if command_and_uri.start_with?('storage/')
			cmnd, checkpoint, device, slot = command_and_uri.split('/')
			storage_slot(device,slot)
		end
	end
end

def download(uri)
	file_name = "barcode-#{Time.now.to_i}.pdf"
	@logger.info "Downloading #{uri} --> /home/tom/Code/suwappu_protocol_handler/tmp/documents/#{file_name}"
	cmnd = "curl #{uri} -o './tmp/documents/#{file_name}'" 
	@logger.info cmnd
	system cmnd
	file_name
end

def print_barcode(local_doc)
	cmnd = "lpr -P 'Zebra-LP2824' ./tmp/documents/#{local_doc}"
	@logger.info cmnd
	system cmnd
end

def storage_slot(device,slot)
	cmnd = "lcdoctl -d #{device} -e #{slot}"
	@logger.info "Storage :: Slot #{slot} @ #{device}"
	system cmnd
end

argument = ARGV[0]
puts argument
puts analyze_uri(argument)
@logger.close

