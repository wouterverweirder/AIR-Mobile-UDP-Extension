package be.aboutme.nativeExtensions.udp.functions;

import be.aboutme.nativeExtensions.udp.UDPSocketAdapter;
import be.aboutme.nativeExtensions.udp.UDPSocketContext;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class Receive implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		
		boolean success = adapter.receive();
		
		FREObject result = null;
		try {
			result = FREObject.newObject(success);
		} catch (FREWrongThreadException e) {
			adapter.log(e);
		}
		
		return result;
	}

}
