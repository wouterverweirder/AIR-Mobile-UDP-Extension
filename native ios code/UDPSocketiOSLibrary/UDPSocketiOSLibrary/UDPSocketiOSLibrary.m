//
//  UDPSocketiOSLibrary.m
//  UDPSocketiOSLibrary
//
//  Created by Wouter Verweirder on 07/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UDPSocketiOSLibrary.h"
#import "UDPSocketAdapter.h"
#import "AsyncUdpSocket.h"

UDPSocketAdapter * adapter;

FREObject Send(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    uint32_t ipLength;
    const uint8_t* ipValue;
    FREGetObjectAsUTF8( argv[1], &ipLength, &ipValue );
    
    uint32_t portValue;
    FREGetObjectAsUint32(argv[2], &portValue);
    
    //Get Byte Array from flash
    FREObject length;
    FREObject objectByteArray = argv[0];
    FREGetObjectProperty(objectByteArray, (const uint8_t*) "length", &length, NULL);   
    
    int numBytes;
    FREGetObjectAsInt32(length, &numBytes);
    
    char * bytes[numBytes];
    
    FREByteArray byteArray;
    FREAcquireByteArray(objectByteArray, &byteArray);
    memcpy(bytes, byteArray.bytes, numBytes);
    FREReleaseByteArray(objectByteArray);
    
    NSString * host = [NSString stringWithUTF8String: (const char * ) ipValue];
    int port = (int) portValue;
    NSData * data = [NSData dataWithBytes:bytes length:numBytes];
    
    [adapter send:data toHost:host port:port];
    
	return NULL;
}

FREObject Bind(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    uint32_t portValue;
    FREGetObjectAsUint32(argv[0], &portValue);
    
    BOOL success = [adapter bind:(int) portValue];
    
    FREObject result;
    FRENewObjectFromBool(success, &result);
    
    return result;
}

FREObject Receive(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{   
    BOOL success = [adapter receive];
    
    FREObject result;
    FRENewObjectFromBool(success, &result);
    
    return result;
}

FREObject ReadPacket(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject result;
    UDPPacket * packet = [adapter readPacket];
    if(packet != nil)
    {
        FREObject type;
        FRENewObjectFromUTF8(4, (const uint8_t *) "data", &type);
        FREObject eventParams [] = {type};
        FRENewObject((const uint8_t *)"flash.events.DatagramSocketDataEvent", 1, eventParams, &result, NULL);
        
        int len = [packet->data length];
        
        FREObject objectByteArray = argv[0];
        
        FREByteArray byteArray;
        FREObject length;
        FRENewObjectFromUint32(len, &length);
        FRESetObjectProperty(objectByteArray, (const uint8_t*) "length", length, NULL);
        FREAcquireByteArray(objectByteArray, &byteArray);
        memcpy(byteArray.bytes, [packet->data bytes], len);
        FREReleaseByteArray(objectByteArray);
        
        FREObject srcAddress;
        FRENewObjectFromUTF8([packet->srcAddress length], (const uint8_t*) [packet->srcAddress cStringUsingEncoding:NSUTF8StringEncoding], &srcAddress);
        FRESetObjectProperty(result, (const uint8_t*) "srcAddress", srcAddress, NULL);
        
        FREObject srcPort;
        FRENewObjectFromUint32(packet->srcPort, &srcPort);
        FRESetObjectProperty(result, (const uint8_t*) "srcPort", srcPort, NULL);
        
        FREObject dstAddress;
        FRENewObjectFromUTF8([packet->dstAddress length], (const uint8_t*) [packet->dstAddress cStringUsingEncoding:NSUTF8StringEncoding], &dstAddress);
        FRESetObjectProperty(result, (const uint8_t*) "dstAddress", dstAddress, NULL);
        
        FREObject dstPort;
        FRENewObjectFromUint32(packet->dstPort, &dstPort);
        FRESetObjectProperty(result, (const uint8_t*) "dstPort", dstPort, NULL);
        
        //release packet data
        [packet->data release];
        [packet->srcAddress release];
        packet->data = nil;
        packet->srcAddress = nil;
    }
    //release it
    [packet release];
    packet = nil;
    //return the result
    return result;
}

FREObject Close(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    BOOL success = [adapter close];
    
    FREObject result;
    FRENewObjectFromBool(success, &result);
    
    return result;
}

FREObject InitNativeCode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    
    NSLog(@"Entering InitNativeCode()");
    
    // Nothing to do.
    
    NSLog(@"Exiting InitNativeCode()");
    
    return NULL;
}

void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    
    NSLog(@"Entering ContextInitializer()");
    
	*numFunctionsToTest = 6;
    
	FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * 6);
	func[0].name = (const uint8_t*) "initNativeCode";
	func[0].functionData = NULL;
    func[0].function = &InitNativeCode;
	
	func[1].name = (const uint8_t*) "send";
	func[1].functionData = NULL;
	func[1].function = &Send;
    
    func[2].name = (const uint8_t*) "bind";
	func[2].functionData = NULL;
	func[2].function = &Bind;
    
    func[3].name = (const uint8_t*) "receive";
	func[3].functionData = NULL;
	func[3].function = &Receive;
    
    func[4].name = (const uint8_t*) "readPacket";
	func[4].functionData = NULL;
	func[4].function = &ReadPacket;
    
    func[5].name = (const uint8_t*) "close";
	func[5].functionData = NULL;
	func[5].function = &Close;
		
	*functionsToSet = func;
    
    adapter = [[UDPSocketAdapter alloc] initWithContext:ctx];
    
    NSLog(@"Exiting ContextInitializer()");
    
}

void ContextFinalizer(FREContext ctx)
{
    
    NSLog(@"Entering ContextFinalizer()");
    
    // cleanup
    [adapter release];
    adapter = nil;
    
    NSLog(@"Exiting ContextFinalizer()");
    
	return;
}

void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                    FREContextFinalizer* ctxFinalizerToSet)
{
    
    NSLog(@"Entering ExtInitializer()");
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;
    
    NSLog(@"Exiting ExtInitializer()");
}


void ExtFinalizer(void* extData) {
    
    NSLog(@"Entering ExtFinalizer()");
    
    // Nothing to clean up.
    
    NSLog(@"Exiting ExtFinalizer()");
    return;
}