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

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		boolean success = false;
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		
		adapter.log("bind called");
		
		try {
			int port = args[0].getAsInt();
			String address = args[1].getAsString();
			adapter.log("port: " + port + " address: " + address);
			success = adapter.bind(port, address);
		} catch (IllegalStateException e) {
			adapter.log(e);
		} catch (FRETypeMismatchException e) {
			adapter.log(e);
		} catch (FREInvalidObjectException e) {
			adapter.log(e);
		} catch (FREWrongThreadException e) {
			adapter.log(e);
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
