package be.aboutme.nativeExtensions.udp;

import java.util.HashMap;
import java.util.Map;

import be.aboutme.nativeExtensions.udp.functions.Bind;
import be.aboutme.nativeExtensions.udp.functions.Close;
import be.aboutme.nativeExtensions.udp.functions.InitNativeCode;
import be.aboutme.nativeExtensions.udp.functions.ReadPacket;
import be.aboutme.nativeExtensions.udp.functions.Receive;
import be.aboutme.nativeExtensions.udp.functions.Send;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class UDPSocketContext extends FREContext {
	
 	private UDPSocketAdapter adapter = null;
	
	public UDPSocketAdapter getAdapter() {
		return adapter;
	}

	public void setAdapter(UDPSocketAdapter adapter) {
		this.adapter = adapter;
	}

	@Override
	public void dispose() {
		if(adapter != null) {
			adapter.dispose();
		}
		adapter = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> map = new HashMap<String, FREFunction>();
		
		map.put("initNativeCode", new InitNativeCode());
		map.put("send", new Send());
		map.put("bind", new Bind());
		map.put("receive", new Receive());
		map.put("readPacket", new ReadPacket());
		map.put("close", new Close());
		
		return map;
	}

}
