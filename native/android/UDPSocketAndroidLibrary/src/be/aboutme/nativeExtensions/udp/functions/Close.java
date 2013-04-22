package be.aboutme.nativeExtensions.udp.functions;

import be.aboutme.nativeExtensions.udp.UDPSocketAdapter;
import be.aboutme.nativeExtensions.udp.UDPSocketContext;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class Close implements FREFunction {

	public FREObject call(FREContext context, FREObject[] args) {
		boolean success = false;
		UDPSocketAdapter adapter = ((UDPSocketContext) context).getAdapter();
		
		success = adapter.close();
		
		FREObject result = null;
		try {
			result = FREObject.newObject(success);
		} catch (FREWrongThreadException e) {
		}
		
		return result;
	}

}
