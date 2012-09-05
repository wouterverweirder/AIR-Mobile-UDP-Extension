package be.aboutme.nativeExtensions.udp;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.nio.channels.DatagramChannel;
import java.util.concurrent.LinkedBlockingQueue;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.text.format.Formatter;

public class UDPSocketAdapter {
	
	private UDPSocketContext context;
	private String address;
	private int port;
	private DatagramChannel channel;
	private DatagramSocket socket;
	
	private UDPListeningThread udpListeningThread;
	private Thread listenThread;
	
	private UDPSendingThread udpSendingThread;
	private Thread sendingThread;
	
	private LinkedBlockingQueue<DatagramPacket>theReceiveQueue;
	private LinkedBlockingQueue<DatagramPacket>theSendQueue;
	
	public UDPSocketAdapter(UDPSocketContext context) {
		this.context = context;
		try {
			channel = DatagramChannel.open();
			socket = channel.socket();
		} catch (SocketException e) {
			log(e);
		} catch (IOException e) {
			log(e);
		}
		theReceiveQueue = new LinkedBlockingQueue<DatagramPacket>();
		theSendQueue = new LinkedBlockingQueue<DatagramPacket>();
	}
	
	private void startSendingThread() {
		if(sendingThread == null) {
			udpSendingThread = new UDPSendingThread(context, socket);
			sendingThread = new Thread(udpSendingThread);
			sendingThread.start();
		}
	}
	
	private void stopSendingThread() {
		if(sendingThread != null) {
			udpSendingThread.stop();
			Thread t = sendingThread;
			sendingThread = null;
			t.interrupt();
		}
	}
	
	private void startListeningThread() {
		if(listenThread == null) {
			udpListeningThread = new UDPListeningThread(context, socket);
			listenThread = new Thread(udpListeningThread);
			listenThread.start();
		}
	}
	
	private void stopListeningThread() {
		if(listenThread != null) {
			udpListeningThread.stop();
			Thread t = listenThread;
			listenThread = null;
			t.interrupt();
		}
	}
	
	public void dispose() {
		close();
	}
	
	public boolean bind(int port) { 
		return bind(port, getLocalIpAddress());
	}
	
	public boolean bind(int port, String host) {
		log("bind on " + host + ":" + port);
		try {
			SocketAddress addr = new InetSocketAddress(host, port);
			socket.bind(addr);
			port = socket.getLocalPort();
			address = socket.getLocalAddress().getHostAddress();
		} catch (SocketException e) {
			log(e);
			return false;
		}
		return true;
	}
	
	public boolean close() {
		stopListeningThread();
		stopSendingThread();
		socket.close();
		return true;
	}
	
	public String getAddress() {
		return address;
	}
	
	public int getPort() {
		return port;
	}
	
	public DatagramPacket readReceivedPacket() {
		return theReceiveQueue.poll();
	}
	
	public DatagramPacket readPacketToSend() {
		return theSendQueue.poll();
	}
	
	public boolean receive() {
		startListeningThread();
		return true;
	}
	
	public boolean send(byte[] data, String ip, int port) {
		if(sendingThread == null) {
			startSendingThread();
		}
		try {
			InetAddress address = InetAddress.getByName(ip);
			DatagramPacket packet = new DatagramPacket(data, data.length, address, port);
			theSendQueue.add(packet);
			return true;
		} catch (UnknownHostException e) {
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
		context.dispatchStatusEventAsync("error", e.getMessage());
	}
	
	public void log(String message) {
		context.dispatchStatusEventAsync("log", message);
	}
	
	public String getLocalIpAddress() {
		ConnectivityManager conMan = (ConnectivityManager) context.getActivity().getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo wifi = conMan.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		if(wifi.isAvailable()) {
			WifiManager wifiMan = (WifiManager) context.getActivity().getSystemService(Context.WIFI_SERVICE);
			WifiInfo wifiInfo = wifiMan.getConnectionInfo();
			return Formatter.formatIpAddress(wifiInfo.getIpAddress());
		}
		return null;
	}
}
