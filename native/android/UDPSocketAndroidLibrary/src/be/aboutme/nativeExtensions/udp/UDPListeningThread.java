package be.aboutme.nativeExtensions.udp;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.nio.channels.DatagramChannel;

public class UDPListeningThread implements Runnable {
	
	private UDPSocketContext ctx;
	
	private DatagramChannel channel;
	private volatile boolean listening;
	
	public UDPListeningThread(UDPSocketContext ctx, DatagramChannel channel) {
		this.ctx = ctx;
		this.channel = channel;
		
		listening = true;
	}

	public void run() {
		try {
			channel.socket().setSoTimeout(1000);
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
				channel.socket().receive(packet);
				ctx.getAdapter().handlePacket(packet);
			} catch(SocketTimeoutException e) {
			} catch(IOException e) {
				listening = false;
				UDPSocketAdapter adapter = ctx.getAdapter();
				if(adapter != null) { //will be null on close
					adapter.sendCloseIfNeeded();
				}
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
