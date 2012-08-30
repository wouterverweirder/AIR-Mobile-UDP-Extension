package be.aboutme.nativeExtensions.udp;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;

public class UDPSendingThread implements Runnable {
	
	private UDPSocketContext ctx;
	
	private DatagramSocket socket;
	
	private volatile boolean running;
	
	public UDPSendingThread(UDPSocketContext ctx, DatagramSocket socket) {
		this.ctx = ctx;
		this.socket = socket;
		
		ctx.getAdapter().log("UDPSendingThread Constructor");
		
		running = true;
	}

	@Override
	public void run() {
		UDPSocketAdapter adapter = ctx.getAdapter();
		
		while(running) {
			DatagramPacket packet = adapter.readPacketToSend();
			while(packet != null) {
				try {
					socket.send(packet);
				} catch (IOException e) {
					adapter.log(e);
				}
				packet = adapter.readPacketToSend();
			}
		}
	}
	
	public void stop() {
		if(running)
		{
			running = false;
		}
	}

}
