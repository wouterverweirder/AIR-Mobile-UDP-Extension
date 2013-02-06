package be.aboutme.nativeExtensions.udp.implementation
{
	import be.aboutme.nativeExtensions.udp.UDPSocket;
	
	import flash.desktop.NativeApplication;
	import flash.errors.IOError;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;
	
	public class NativeImplementation implements IUDPSocketImplementation
	{
		
		private var extContext:ExtensionContext;
		private static var initialized:Boolean;
		private static var sharedContext:ExtensionContext;
		private static var _isSupported:Boolean;
		
		private var udpSocket:UDPSocket;
		
		public function NativeImplementation(udpSocket:UDPSocket)
		{
			this.udpSocket = udpSocket;
			
			extContext = ExtensionContext.createExtensionContext("be.aboutme.nativeExtensions.udp.UDPSocket", null);
			extContext.addEventListener(StatusEvent.STATUS, statusHandler);
			extContext.call("initNativeCode");
			if(NativeApplication.nativeApplication != null)
			{
				NativeApplication.nativeApplication.addEventListener("close", nativeApplicationCloseHandler, false, 0, true);
			}
		}
		
		public static function get isSupported():Boolean
		{
			if(!initialized)
			{
				initialized = true;
				sharedContext = ExtensionContext.createExtensionContext("be.aboutme.nativeExtensions.udp.UDPSocket", "shared");
				if(sharedContext)
				{
					try
					{
						sharedContext.call("isSupported");
						_isSupported = true;
					}
					catch(e:Error)
					{
					}
				}
			}
			return _isSupported;
		}
		
		protected function nativeApplicationCloseHandler(event:Event):void
		{
			dispose();
		}
		
		protected function statusHandler(event:StatusEvent):void
		{
			switch(event.code)
			{
				case "receive":
					var bytes:ByteArray = new ByteArray();
					var packet:DatagramSocketDataEvent = extContext.call("readPacket", bytes) as DatagramSocketDataEvent;
					while(packet != null)
					{
						packet.data = bytes;
						udpSocket.dispatchEvent(packet);
						bytes = new ByteArray();
						packet = extContext.call("readPacket", bytes) as DatagramSocketDataEvent;
					}
					break;
				default:
					trace(event.code, event.level);
					break;
			}
		}
		
		public function send(bytes:ByteArray, address:String, port:uint):void
		{
			extContext.call("send", bytes, address, port) as Boolean;
		}
		
		public function bind(port:uint, localAddress:String = "0.0.0.0"):void
		{
			var success:Boolean = extContext.call("bind", port, localAddress);
			if(!success)
			{
				throw new IOError("UDPSocket could not be bound!");
			}
		}

		public function receive():void
		{
			extContext.call("receive");
		}
		
		public function close():void
		{
			dispose();
		}
		
		protected function dispose():void
		{
			if(extContext != null)
			{
				extContext.removeEventListener(StatusEvent.STATUS, statusHandler);
				extContext.dispose();
				extContext = null;
			}
			if(NativeApplication.nativeApplication != null)
			{
				NativeApplication.nativeApplication.removeEventListener("close", nativeApplicationCloseHandler);
			}
		}
	}
}