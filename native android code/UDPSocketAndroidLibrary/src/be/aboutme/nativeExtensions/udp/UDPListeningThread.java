package be.aboutme.nativeExtensions.udp;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;
import java.net.SocketTimeoutException;

public class UDPListeningThread implements Runnable {
	
	private UDPSocketContext ctx;
	
	private DatagramSocket socket;
	private volatile boolean listening;
	
	public UDPListeningThread(UDPSocketContext ctx, DatagramSocket socket) {
		this.ctx = ctx;
		this.socket = socket;
		
		ctx.getAdapter().log("UDPListeningThread Constructor");
		
		listening = true;
	}

	@Override
	public void run() {
		
		UDPSocketAdapter adapter = ctx.getAdapter();
		
		adapter.log("run method");
		
		try {
			socket.setSoTimeout(1000);
			adapter.log("set timeout");
		} catch (SocketException e) {
			listening = false;
			adapter.log(e);
		}
			
		byte[] packetContent;
		DatagramPacket packet;
		
		while(listening) {
			packetContent = new byte[1024];
			packet = new DatagramPacket(packetContent, packetContent.length);
			
			try
			{
				socket.receive(packet);
				ctx.getAdapter().handlePacket(packet);
			} catch(SocketTimeoutException e) {
				//timeout, just continue
			} catch(IOException e) {
				listening = false;
				adapter.log(e);
			}
		}
	}
	
	public void stop() {
		if(listening)
		{
			socket.close();
			listening = false;
		}
	}

}
