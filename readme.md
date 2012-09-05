#AIR Mobile UDP extension

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

Make sure you request the following permissions for Android Usage:

	<uses-permission android:name="android.permission.INTERNET"/>
	<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
	<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>