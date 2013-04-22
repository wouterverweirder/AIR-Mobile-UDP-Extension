package be.aboutme.nativeExtensions.udp.functions;

import java.net.DatagramPacket;
import java.nio.ByteBuffer;

import be.aboutme.nativeExtensions.udp.UDPSocketAdapter;
import be.aboutme.nativeExtensions.udp.UDPSocketContext;

import com.adobe.fre.FREASErrorException;
import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FRENoSuchNameException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREReadOnlyException;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class ReadPacket implements FREFunction {

	public FREObject call(FREContext context, FREObject[] args) {
		
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		
		FREObject result  = null;
		DatagramPacket packet = adapter.readReceivedPacket();
		if(packet != null) {			
			try {
				
				FREObject[] eventArgs = new FREObject[1];
				eventArgs[0] = FREObject.newObject("data");
				result = FREObject.newObject("flash.events.DatagramSocketDataEvent", eventArgs);
				
				byte[] packetBytes = packet.getData();
				
				FREByteArray byteArray = (FREByteArray) args[0];
				byteArray.setProperty("length", FREObject.newObject(packetBytes.length));
				byteArray.acquire();
				ByteBuffer bytes = byteArray.getBytes();
				bytes.position(0);
				bytes.put(packet.getData());
				byteArray.release();
				
				result.setProperty("srcAddress", FREObject.newObject(packet.getAddress().getHostAddress()));
				result.setProperty("srcPort", FREObject.newObject(packet.getPort()));
				result.setProperty("dstAddress", FREObject.newObject(adapter.getAddress()));
				result.setProperty("dstPort", FREObject.newObject(adapter.getPort()));
				
			} catch (IllegalStateException e) {
			} catch (FRETypeMismatchException e) {
			} catch (FREInvalidObjectException e) {
			} catch (FREASErrorException e) {
			} catch (FRENoSuchNameException e) {
			} catch (FREWrongThreadException e) {
			} catch (FREReadOnlyException e) {
			}
		}
		
		return result;
	}

}
