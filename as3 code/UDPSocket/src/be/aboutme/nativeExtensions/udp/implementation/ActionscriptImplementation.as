package be.aboutme.nativeExtensions.udp.implementation
{
	import be.aboutme.nativeExtensions.udp.UDPSocket;
	
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;
	
	public class ActionscriptImplementation implements IUDPSocketImplementation
	{
		
		private var udpSocket:UDPSocket;
		private var datagramSocket:DatagramSocket;
		
		public function ActionscriptImplementation(udpSocket:UDPSocket)
		{
			this.udpSocket = udpSocket;
			datagramSocket = new DatagramSocket();
			datagramSocket.addEventListener(DatagramSocketDataEvent.DATA, dataHandler, false, 0, true);
		}
		
		protected function dataHandler(event:DatagramSocketDataEvent):void
		{
			udpSocket.dispatchEvent(event.clone());
		}
		
		public function send(bytes:ByteArray, address:String, port:uint):void
		{
			datagramSocket.send(bytes, 0, 0, address, port);
		}
		
		public function bind(port:uint, localAddress:String="0.0.0.0"):void
		{
			datagramSocket.bind(port, localAddress);
		}
		
		public function receive():void
		{
			datagramSocket.receive();
		}
		
		public function close():void
		{
			datagramSocket.close();
		}
	}
}