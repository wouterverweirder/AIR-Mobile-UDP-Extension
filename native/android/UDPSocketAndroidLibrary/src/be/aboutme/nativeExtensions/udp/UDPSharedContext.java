package be.aboutme.nativeExtensions.udp;

import java.util.HashMap;
import java.util.Map;

import be.aboutme.nativeExtensions.udp.functions.IsSupported;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class UDPSharedContext extends FREContext {

	@Override
	public void dispose() {
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> map = new HashMap<String, FREFunction>();
		
		map.put("isSupported", new IsSupported());
		
		return map;
	}

}
