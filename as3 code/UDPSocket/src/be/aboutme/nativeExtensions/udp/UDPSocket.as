/**
 * UDPSocket.as
 * Wouter Verweirder
 * version 1.0.1
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
	import be.aboutme.nativeExtensions.udp.implementation.ActionscriptImplementation;
	import be.aboutme.nativeExtensions.udp.implementation.IUDPSocketImplementation;
	import be.aboutme.nativeExtensions.udp.implementation.NativeImplementation;
	
	import flash.events.DatagramSocketDataEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * The UDPSocket class enables code to send and receive
	 * Universal Datagram Packets (UDP) on AIR for iOS projects.
	 */
	[Event(name="data", type="flash.events.DatagramSocketDataEvent")]
	public class UDPSocket extends EventDispatcher
	{

		private var implementation:IUDPSocketImplementation;
		
		/**
		 * UDPSocket constructor
		 */ 
		public function UDPSocket()
		{
			if(NativeImplementation.isSupported)
			{
				implementation = new NativeImplementation(this);
			}
			else
			{
				implementation = new ActionscriptImplementation(this);
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
			implementation.send(bytes, address, port);
		}
		
		/**
		 * Binds this socket to the specified local port.
		 * @param port		The number of the local port to bind to.
		 * @param localAddress The local ip address to bind to.
		 */ 
		public function bind(port:uint, localAddress:String = "0.0.0.0"):void
		{
			implementation.bind(port, localAddress);
		}
		
		/**
		 * Enables this UDPSocket object to receive incoming packets on the bound port.
		 */ 
		public function receive():void
		{
			implementation.receive();
		}
		
		/**
		 * Closes the UDPSocket
		 * 
		 * a closed socket cannot be reused
		 */ 
		public function close():void
		{
			implementation.close();
		}
	}
}