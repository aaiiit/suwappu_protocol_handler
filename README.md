== README

Application used to handle suwappu:// protocol.


== Prerequisities

	*	Ubuntu
	*	Barcode printer must be installed for printing
  * Scanner must be installed for scanning (scanimage -L)
  * Dacal machine should be working through commands
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


= Add to Iceweasel

  You may try to edit Firefox configuration via about:config:

  * network.protocol-handler.expose.komodo: true (This protocol should be handled either by the browser or by an external application)
  * network.protocol-handler.external.komodo: true (This protocol should be handled by an external application)
  * network.protocol-handler.app.komodo: python /path/to/my/script.py (Path to a program to handle the request)
