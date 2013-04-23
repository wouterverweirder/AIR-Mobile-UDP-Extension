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
import android.os.AsyncTask;
import android.text.format.Formatter;

public class UDPSocketAdapter {
	
	private UDPSocketContext context;
	private String address;
	private int port;
	private DatagramChannel channel;
	private DatagramSocket socket;
	
	private Boolean hasDispatchedClose;
	
	private UDPListeningThread udpListeningThread;
	private Thread listenThread;
	
	private LinkedBlockingQueue<DatagramPacket>theReceiveQueue;
	
	public UDPSocketAdapter(UDPSocketContext context) {
		this.context = context;
		
		try {
			channel = DatagramChannel.open();
			socket = channel.socket();
		} catch (SocketException e) {
		} catch (IOException e) {
		}
		theReceiveQueue = new LinkedBlockingQueue<DatagramPacket>();
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
		try {
			SocketAddress addr = new InetSocketAddress(host, port);
			socket.bind(addr);
			port = socket.getLocalPort();
			address = socket.getLocalAddress().getHostAddress();
		} catch (SocketException e) {
			return false;
		}
		return true;
	}
	
	public boolean close() {
		stopListeningThread();
		socket.close();
		return true;
	}
	
	public void dispatchClose() {
		if(!hasDispatchedClose) {
			hasDispatchedClose = true;
			context.dispatchStatusEventAsync("close", "");
		}
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
	
	public boolean receive() {
		startListeningThread();
		return true;
	}
	
	public boolean send(byte[] data, String ip, int port) {
		try {
			InetAddress address = InetAddress.getByName(ip);
			DatagramPacket packet = new DatagramPacket(data, data.length, address, port);
			new SendUDPTask().execute(packet);
			return true;
		} catch (UnknownHostException e) {
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
	
	private class SendUDPTask extends AsyncTask<DatagramPacket, Integer, Boolean> {

		@Override
		protected Boolean doInBackground(DatagramPacket... params) {
			try {
				socket.send(params[0]);
			} catch (IOException e) {
			}
			return true;
		}
		
	}
}