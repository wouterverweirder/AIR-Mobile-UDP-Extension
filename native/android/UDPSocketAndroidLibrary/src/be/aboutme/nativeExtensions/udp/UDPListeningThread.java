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
		
		listening = true;
	}

	public void run() {
		try {
			socket.setSoTimeout(1000);
		} catch (SocketException e) {
			listening = false;
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
			}
		}
	}
	
	public void stop() {
		if(listening)
		{
			listening = false;
		}
	}

}
