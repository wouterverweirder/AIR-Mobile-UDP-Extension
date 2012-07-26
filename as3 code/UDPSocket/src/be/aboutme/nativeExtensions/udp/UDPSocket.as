/**
 * UDPSocket.as
 * Wouter Verweirder
 * version 0.1.0
 * 
 * The UDPSocket class enables code to send and receive
 * Universal Datagram Packets (UDP) on AIR for iOS projects.
 * 
 * Copyright (c) 2011 Wouter Verweirder
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package be.aboutme.nativeExtensions.udp
{
	import flash.desktop.NativeApplication;
	import flash.errors.IOError;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.utils.ByteArray;
	
	/**
	 * The UDPSocket class enables code to send and receive
	 * Universal Datagram Packets (UDP) on AIR for iOS projects.
	 */
	[Event(name="data", type="flash.events.DatagramSocketDataEvent")]
	public class UDPSocket extends EventDispatcher
	{

		private var extContext:ExtensionContext = null;
		
		/**
		 * UDPSocket constructor
		 */ 
		public function UDPSocket()
		{
			extContext = ExtensionContext.createExtensionContext("be.aboutme.nativeExtensions.udp.UDPSocket", null);
			extContext.addEventListener(StatusEvent.STATUS, statusHandler);
			extContext.call("initNativeCode");
			//auto-dispose on application exit
			if(NativeApplication.nativeApplication != null)
			{
				NativeApplication.nativeApplication.addEventListener("close", nativeApplicationCloseHandler, false, 0, true);
			}
		}
		
		protected function nativeApplicationCloseHandler(event:Event):void
		{
			dispose();
		}
		
		/**
		 * This event handler is called when the extension context dispatches
		 * status events from the native extension.
		 */ 
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
						dispatchEvent(packet);
						bytes = new ByteArray();
						packet = extContext.call("readPacket", bytes) as DatagramSocketDataEvent;
					}
					break;
				default:
					trace(event.code, event.level);
					break;
			}
		}
		
		/**
		 * Sends packet containing the bytes in the ByteArray using UDP.
		 * @param bytes		a ByteArray containing the packet data.
		 * @param address	The IPv4 or IPv6 address of the remote machine.
		 * @param port		The port number on the remote machine. A value greater than 0 and less than 65536 is required.
		 */ 
		public function send(bytes:ByteArray, address:String, port:uint):void
		{
			if(extContext != null)
			{
				extContext.call("send", bytes, address, port) as Boolean;
			}
		}
		
		/**
		 * Binds this socket to the specified local port.
		 * @param port		The number of the port to bind to on the local computer.
		 */ 
		public function bind(port:uint, localAddress:String = "0.0.0.0"):void
		{
			if(extContext != null)
			{
				var success:Boolean = extContext.call("bind", port, localAddress);
				if(!success)
				{
					//throw an error
					throw new IOError("UDPSocket could not be bound!");
				}
			}
		}
		
		/**
		 * Enables this UDPSocket object to receive incoming packets on the bound port.
		 */ 
		public function receive():void
		{
			if(extContext != null)
			{
				extContext.call("receive");
			}
		}
		
		/**
		 * Closes the UDPSocket
		 * 
		 * a closed socket cannot be reused
		 */ 
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
		}
	}
}