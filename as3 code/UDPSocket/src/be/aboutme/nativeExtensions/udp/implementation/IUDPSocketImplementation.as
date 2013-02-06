package be.aboutme.nativeExtensions.udp.implementation
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	public interface IUDPSocketImplementation
	{
		function send(bytes:ByteArray, address:String, port:uint):void;
		function bind(port:uint, localAddress:String = "0.0.0.0"):void;
		function receive():void;
		function close():void;
	}
}