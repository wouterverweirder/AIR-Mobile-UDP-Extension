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

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		adapter.log("ReadPacket called");
		
		FREObject result  = null;
		DatagramPacket packet = adapter.readPacket();
		adapter.log("packet: " + packet);
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
				adapter.log(e);
			} catch (FRETypeMismatchException e) {
				adapter.log(e);
			} catch (FREInvalidObjectException e) {
				adapter.log(e);
			} catch (FREASErrorException e) {
				adapter.log(e);
			} catch (FRENoSuchNameException e) {
				adapter.log(e);
			} catch (FREWrongThreadException e) {
				adapter.log(e);
			} catch (FREReadOnlyException e) {
				adapter.log(e);
			}
		}
		
		return result;
	}

}
