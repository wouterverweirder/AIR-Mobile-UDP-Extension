package be.aboutme.nativeExtensions.udp;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class UDPSocketAndroidLibrary implements FREExtension {

	public FREContext createContext(String arg0) {
		if("shared".equals(arg0)) {
			return new UDPSharedContext();
		}
		return new UDPSocketContext();
	}

	public void dispose() {
		
	}

	public void initialize() {

	}

}
