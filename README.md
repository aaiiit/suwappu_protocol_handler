== README

Application used to handle suwappu:// protocol.


== Prerequisities

	*	Ubuntu
	*	Barcode printer must be installed
	* Chrome


== Installation

	*	Download
	*	Make sure handler.rb is executable
	* Create suwappu.desktop in /usr/share/applications/
	* Configure correct paths in suwappu.desktop and handler.rb


== suwappu.desktop
	[Desktop Entry]
	Type=Application
	Name=Suwappu
	GenericName=Suwappu
	Exec=/home/tom/Code/suwappu_protocol_handler/handler %U
	Icon=arduino
	Terminal=false
	Categories=Development;Engineering;Electronics;
	MimeType=text/x-suwappu;x-scheme-handler/suwappu;
