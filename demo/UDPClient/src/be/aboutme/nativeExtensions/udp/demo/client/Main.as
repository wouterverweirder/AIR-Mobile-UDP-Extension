package be.aboutme.nativeExtensions.udp.demo.client
{
	import be.aboutme.nativeExtensions.udp.UDPSocket;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollText;
	import feathers.controls.TextInput;
	import feathers.themes.MetalWorksMobileTheme;
	
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.ByteArray;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Main extends Sprite
	{
		
		private var theme:MetalWorksMobileTheme;
		
		private var udpSocket:UDPSocket;
		private var defaultTextMessage:String = "Hello World!";
		
		private var outputText:ScrollText;
		
		private var inputContainer:Sprite;
		
		private var messageLabel:Label;
		private var messageInput:TextInput;
		
		private var ipLabel:Label;
		private var ipInput:TextInput;
		
		private var portLabel:Label;
		private var portInput:TextInput;
		
		private var sendButton:Button;

		public function Main()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			theme = new MetalWorksMobileTheme(stage);
			
			udpSocket = new UDPSocket();
			udpSocket.addEventListener(DatagramSocketDataEvent.DATA, udpDataHandler);
			udpSocket.addEventListener("close", udpCloseHandler);
			udpSocket.bind(1235);
			udpSocket.receive();
			
			outputText = new ScrollText();
			outputText.text = "UDPSocket Initialized\n";
			addChild(outputText);
			
			inputContainer = new Sprite();
			addChild(inputContainer);
			
			messageLabel = new Label();
			messageLabel.text = "Message:";
			inputContainer.addChild(messageLabel);
			
			messageInput = new TextInput();
			messageInput.text = defaultTextMessage;
			inputContainer.addChild(messageInput);
			
			ipLabel = new Label();
			ipLabel.text = "Target IP:";
			inputContainer.addChild(ipLabel);
			
			ipInput = new TextInput();
			ipInput.text = "255.255.255.255";
			inputContainer.addChild(ipInput);
			
			portLabel = new Label();
			portLabel.text = "Target Port:";
			inputContainer.addChild(portLabel);
			
			portInput = new TextInput();
			portInput.text = "1234";
			inputContainer.addChild(portInput);
			
			sendButton = new Button();
			sendButton.label = "Send";
			inputContainer.addChild(sendButton);
			
			layout();
			stage.addEventListener(Event.RESIZE, layout);
			
			sendButton.addEventListener(Event.TRIGGERED, sendTriggeredHandler);
		}
		
		protected function udpCloseHandler(event:flash.events.Event):void
		{
			outputText.text += "UDPSocket Closed\n";
		}
		
		protected function sendTriggeredHandler(event:Event):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(messageInput.text + "\n");
			messageInput.text = defaultTextMessage;
			udpSocket.send(bytes, ipInput.text, int(portInput.text));
		}
		
		protected function udpDataHandler(event:DatagramSocketDataEvent):void
		{
			try
			{
				var o:Object = event.data.readObject();
				switch(o.command)
				{
					default:
						outputText.text += "unknown command: " + o.command + "\n";
						break;
				}
			}
			catch(e:Error)
			{
				event.data.position = 0;
				outputText.text += event.data.readUTFBytes(event.data.bytesAvailable);
			}
			outputText.verticalScrollPosition = outputText.maxVerticalScrollPosition;
		}
		
		private function layout(...rest):void
		{
			messageLabel.validate();
			
			messageInput.width = stage.stageWidth - 20;
			messageInput.y = messageLabel.y + messageLabel.height + 10;
			messageInput.validate();
			
			ipLabel.y = messageInput.y + messageInput.height + 10;
			ipLabel.validate();
			
			ipInput.width = messageInput.width;
			ipInput.y = ipLabel.y + ipLabel.height + 10;
			ipInput.validate();
			
			portLabel.y = ipInput.y + ipInput.height + 10;
			portLabel.validate();
			
			portInput.width = messageInput.width;
			portInput.y = portLabel.y + portLabel.height + 10;
			portInput.validate();
			
			sendButton.width = messageInput.width;
			sendButton.y = portInput.y + portInput.height + 10;
			sendButton.validate();
			
			inputContainer.x = 10;
			inputContainer.y = stage.stageHeight - sendButton.y - sendButton.height - 10;
			
			outputText.setSize(stage.stageWidth, inputContainer.y);
		}
	}
}