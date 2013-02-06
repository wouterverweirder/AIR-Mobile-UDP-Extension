package be.aboutme.nativeExtensions.udp.functions;

import java.nio.ByteBuffer;

import be.aboutme.nativeExtensions.udp.UDPSocketAdapter;
import be.aboutme.nativeExtensions.udp.UDPSocketContext;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class Send implements FREFunction {

	public FREObject call(FREContext context, FREObject[] args) {

		boolean success = false;
		
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		
		FREByteArray byteArray = (FREByteArray) args[0];
		
		if(byteArray != null)
		{
			try {
				String ip = args[1].getAsString();
				int port = args[2].getAsInt();
				byteArray.acquire();
				ByteBuffer byteBuffer = byteArray.getBytes();
				byte bytes[] = new byte[byteBuffer.limit()];
				byteBuffer.get(bytes);
				byteArray.release();
				success = adapter.send(bytes, ip, port);
				
			} catch (IllegalStateException e) {
				adapter.log(e);
			} catch (FRETypeMismatchException e) {
				adapter.log(e);
			} catch (FREInvalidObjectException e) {
				adapter.log(e);
			} catch (FREWrongThreadException e) {
				adapter.log(e);
			}
		}
		
		FREObject result = null;
		try {
			result = FREObject.newObject(success);
		} catch (FREWrongThreadException e) {
			adapter.log(e);
		}
		
		return result;
	}

}
