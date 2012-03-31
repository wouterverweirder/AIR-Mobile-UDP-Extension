package be.aboutme.nativeExtensions.udp;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class UDPSocketAndroidLibrary implements FREExtension {

	@Override
	public FREContext createContext(String arg0) {
		return new UDPSocketContext();
	}

	@Override
	public void dispose() {
		
	}

	@Override
	public void initialize() {

	}

}
