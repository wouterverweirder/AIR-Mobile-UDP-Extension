package be.aboutme.nativeExtensions.udp;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.concurrent.LinkedBlockingQueue;

public class UDPSocketAdapter {
	
	private UDPSocketContext context;
	private String address;
	private int port;
	private DatagramSocket sendSocket;
	private DatagramSocket receiveSocket;
	private UDPListeningThread run;
	private Thread receiveThread;
	private LinkedBlockingQueue<DatagramPacket>theReceiveQueue;
	
	public UDPSocketAdapter(UDPSocketContext context) {
		this.context = context;
		log("created UDP Socket Adapter");
		try {
			sendSocket = new DatagramSocket();
		} catch (SocketException e) {
			log(e);
		}
		theReceiveQueue = new LinkedBlockingQueue<DatagramPacket>();
	}
	
	public void dispose() {
		close();
	}
	
	public boolean bind(int port) { 
		try {
			this.receiveSocket = new DatagramSocket(port);
			
			this.port = receiveSocket.getLocalPort();
			this.address = receiveSocket.getLocalAddress().getHostAddress();
		} catch (SocketException e) {
			log(e);
			return false;
		}
		return true;
	}
	
	public boolean bind(int port, String host) {
		try {
			SocketAddress addr = new InetSocketAddress(host, port);
			this.receiveSocket = new DatagramSocket(addr);
			this.port = receiveSocket.getLocalPort();
			this.address = receiveSocket.getLocalAddress().getHostAddress();
		} catch (SocketException e) {
			log(e);
			return false;
		}
		return true;
	}
	
	public boolean close() {
		if(receiveThread != null) {
			run.stop();
			Thread t = receiveThread;
			receiveThread = null;
			t.interrupt();
		}
		return true;
	}
	
	public String getAddress() {
		return address;
	}
	
	public int getPort() {
		return port;
	}
	
	public DatagramPacket readPacket() {
		return theReceiveQueue.poll();
	}
	
	public boolean receive() {
		
		log("execute receive");
		
		run = new UDPListeningThread(context, receiveSocket);
		receiveThread = new Thread(run);
		
		log("retrievethread created");
		
		receiveThread.start();
		
		return true;
	}
	
	public boolean send(byte[] data, String ip, int port) {
		try {
			InetAddress address = InetAddress.getByName(ip);
			DatagramPacket packet = new DatagramPacket(data, data.length, address, port);
			sendSocket.send(packet);
			return true;
		} catch (UnknownHostException e) {
			log(e);
		} catch (IOException e) {
			log(e);
		}
		
		return false;
	}

	public void handlePacket(DatagramPacket packet) {
		//set the correct packet byte size
		byte[] src = packet.getData();
		byte[] dst = new byte[packet.getLength()];
		System.arraycopy(src, 0, dst, 0, dst.length);
		packet.setData(dst);
		//add it to the queue
		theReceiveQueue.add(packet);
		//notify the context
		context.dispatchStatusEventAsync("receive", "");
	}
	
	public void log(Exception e) {
		//context.dispatchStatusEventAsync("error", e.getMessage());
	}
	
	public void log(String message) {
		//context.dispatchStatusEventAsync("log", message);
	}
}
