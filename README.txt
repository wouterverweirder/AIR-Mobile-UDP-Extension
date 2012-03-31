Author: Wouter Verweirder

The UDPSocket class enables code to send and receive
Universal Datagram Packets (UDP) on AIR for iOS & Android projects.

It uses a native extension to give you this functionality.
The extension id for the native extension is: be.aboutme.nativeExtensions.udp.UDPSocket

To send a packet over UDP:

var udpSocket:UDPSocket = new UDPSocket();
var bytes:ByteArray = new ByteArray();
bytes.writeUTFBytes("Hello World");
udpSocket.send(bytes, "192.168.9.1", 1234);

To listen for inbound UDP traffic:

var udpSocket:UDPSocket = new UDPSocket();
udpSocket.addEventListener(DatagramSocketDataEvent.DATA, udpDataHandler);
udpSocket.bind(1234);
udpSocket.receive();

protected function udpDataHandler(event:DatagramSocketDataEvent):void
{
	trace(event.data);
}