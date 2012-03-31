package be.aboutme.nativeExtensions.udp.functions;

import be.aboutme.nativeExtensions.udp.UDPSocketAdapter;
import be.aboutme.nativeExtensions.udp.UDPSocketContext;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class InitNativeCode implements FREFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		((UDPSocketContext) context).setAdapter(new UDPSocketAdapter((UDPSocketContext) context));
		
		return null;
	}

}
