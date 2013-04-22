package be.aboutme.nativeExtensions.udp.functions;

import be.aboutme.nativeExtensions.udp.UDPSocketAdapter;
import be.aboutme.nativeExtensions.udp.UDPSocketContext;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class Bind implements FREFunction {

	public FREObject call(FREContext context, FREObject[] args) {
		
		boolean success = false;
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		
		try {
			int port = args[0].getAsInt();
			String address = args[1].getAsString();
			if(address.equals("0.0.0.0")) success = adapter.bind(port);
			else success = adapter.bind(port, address);
		} catch (IllegalStateException e) {
		} catch (FRETypeMismatchException e) {
		} catch (FREInvalidObjectException e) {
		} catch (FREWrongThreadException e) {
		}
		
		FREObject result = null;
		try {
			result = FREObject.newObject(success);
		} catch (FREWrongThreadException e) {
		}
		
		return result;
	}

}
